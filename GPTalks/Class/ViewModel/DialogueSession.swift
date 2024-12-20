//
//  DialogueSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI
import PDFKit
import OpenAI

@Observable class DialogueSession: Identifiable, Equatable, Hashable {
    struct Configuration: Codable {
        var temperature: Double
        var systemPrompt: String
        var provider: Provider
        var model: Model

        init() {
            provider = AppConfiguration.shared.preferredChatService
            model = provider.preferredChatModel
            temperature = AppConfiguration.shared.temperature
            systemPrompt = AppConfiguration.shared.systemPrompt
        }
    }

    // MARK: - Hashable, Equatable

    static func == (lhs: DialogueSession, rhs: DialogueSession) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id = UUID()

    var rawData: DialogueData?

    // MARK: - State
    
    var input: String = ""
    var inputImages: [String] = []
    var inputAudioPath: String = ""
    var inputPDFPath: String = ""
    
    var isEditing: Bool = false
    var editingMessage: String = ""
    var editingAudioPath: String = ""
    var editingImages: [String] = []
    var editingPDFPath: String = ""
    var editingIndex: Int = -1
    
    var isAddingConversation: Bool = false
    
    var title: String = "New Session"
    var conversations: [Conversation] = []
    var date = Date()
    var errorDesc: String = ""
    var configuration: Configuration = Configuration() {
        didSet {
            save()
        }
    }

    var resetMarker: Int = -1
    var isArchive = false
    var isStreaming = false
    
    var shouldSwitchToVision: Bool {
        return adjustedConversations.contains(where: { ($0.role == .user || $0.role == .assistant) && !$0.imagePaths.isEmpty }) || inputImages.count > 0
    }

    // MARK: - Properties

    var lastMessage: String {
        if errorDesc != "" {
            return errorDesc
        }
        return conversations.last?.content ?? "Start a new conversation"
    }

    var lastConversation: Conversation {
        return conversations[conversations.count - 1]
    }
    
    var adjustedConversations: [Conversation] {
        if conversations.count > resetMarker + 1 {
            return Array(conversations.suffix(from: resetMarker + 1))
        }
        return []
    }
    
    var streamingTask: Task<Void, Error>?
    var viewUpdater: Task<Void, Error>?

    var isReplying: Bool {
        return !conversations.isEmpty && lastConversation.isReplying
    }
    
    func getModels() async {
        let config = configuration.provider.config
        let service: OpenAI = OpenAI(configuration: config)
        
        do {
            print(try await service.models())
        } catch {
            print("Error: \(error)")
        }
    }

    init() {
    }
    
    init(configuration: DialogueSession.Configuration) {
        self.configuration = configuration
    }

    // MARK: - Message Actions
    
    func toggleArchive() {
        isArchive.toggle()
        save()
    }

    func removeResetContextMarker() {
        withAnimation {
            resetMarker = -1
        }
        save()
    }
    
    func forkSession(conversation: Conversation) -> [Conversation] {
        // Assuming 'conversations' is an array of Conversation objects available in this scope
        if let index = conversations.firstIndex(of: conversation) {
            // Create a new array containing all conversations up to and including the one at the found index
            var forkedConversations = Array(conversations.prefix(through: index))
            
            // Remove all conversations after the found index from the original conversations array
            forkedConversations.removeSubrange((index + 1)...)

            // Return the forked conversations
            return forkedConversations
        } else {
            // If the conversation is not found, you might want to handle this case differently.
            // For now, returning an empty array or the original list based on your requirements might be a good idea.
            return []
        }
    }
    
    @MainActor
    func generateTitle(forced: Bool = false) async {
        // TODO; the new session check dont work nicely
        if conversations.count == 1 || conversations.count == 2 || (forced && conversations.count >= 2) {
            if title != "New Session" && !forced {
                return
            }
                
            let openAIconfig = configuration.provider.config
            let service: OpenAI = OpenAI(configuration: openAIconfig)
            
            let taskMessage = Conversation(role: .user, content: "Generate a title of a chat based on the whole conversation. Return only the title of the conversation and nothing else. Do not include any quotation marks or anything else. Keep the title within 2-3 words and never exceed this limit. If there are multiple distinct topics being talked about, make the title about the most recent topic. Do not acknowledge these instructions but definitely do follow them. Again, do not put the title in quoation marks. Do not put any punctuation at all.")
            
            let messages = (conversations + [taskMessage]).map({ conversation in
                conversation.toChat(imageAsPath: true)
            })
            
            let query = ChatQuery(messages: messages,
                                  model: configuration.model.id,
                                  maxTokens: 10,
                                  stream: false)
            
            var tempTitle = ""
            
            do {
                for try await result in service.chatsStream(query: query) {
                    tempTitle += result.choices.first?.delta.content ?? ""
                    title = tempTitle
                }
                
                save()
            } catch {
                if forced {
                    print("Ensure at least two messages to generate a title.")
                } else {
                    print("genuine error.")
                }
            }
        }
    }
    
    #if os(macOS)
    func pasteImageFromClipboard() {
        if let image = getImageFromClipboard() {
//            let imageData = image.tiffRepresentation
            
            if isEditing {
                if let filePath = saveImage(image: image), !editingImages.contains(filePath) {
                    self.editingImages.append(filePath)
                }
            } else {
                if let filePath = saveImage(image: image), !inputImages.contains(filePath) {
                    self.inputImages.append(filePath)
                }
            }
        }
    }

    #endif

    func setResetContextMarker(conversation: Conversation) {
        if let index = conversations.firstIndex(of: conversation) {
            // animation only if the one being reset is not the last one
            if index != conversations.count - 1 {
                withAnimation {
                    resetMarker = index
                }
            } else {
                resetMarker = index
            }
        }

        save()
    }

    func resetContext() {
        if conversations.isEmpty {
            return
        }
            if resetMarker == conversations.count - 1 {
                withAnimation {
                    removeResetContextMarker()
                }
            } else {
                resetMarker = conversations.count - 1
            }

        save()
    }

    @MainActor
    func stopStreaming() {
        if let lastConcersationContent = conversations.last?.content, lastConcersationContent.isEmpty {
            removeConversation(at: conversations.count - 1)
        }
        streamingTask?.cancel()
        streamingTask = nil
        
        if let _ = conversations.last {
            conversations[conversations.count - 1].isReplying = false
        }
    }
    
    @MainActor
    func sendAppropriate() async {
        if isEditing {
            if editingMessage.isEmpty {
                return
            }
            await edit()
        } else {
            if input.isEmpty {
                return
            }
            await send()
        }
    }

    @MainActor
    func send() async {
        let text = input
        input = ""
        await send(text: text)
    }

    func rename(newTitle: String) {
        title = newTitle
        save()
    }
    
    @MainActor
    func retry() async {
        if lastConversation.content.isEmpty {
            removeConversations(from: conversations.count - 1)
        }
        
        await send(text: lastConversation.content, isRetry: true)
    }

    @MainActor
    func regenerateLastMessage() async {
        if conversations.isEmpty {
            return
        }

        if conversations[conversations.count - 1].role != .user {
            removeConversations(from: conversations.count - 1)
        }
        await send(text: lastConversation.content, isRegen: true)
    }

    @MainActor
    func regenerate(from conversation: Conversation) async {
        if let index = conversations.firstIndex(of: conversation) {
            if index <= resetMarker {
                removeResetContextMarker()
            }
            
            if conversations[index].role == .assistant {
                removeConversations(from: index)
                await send(text: lastConversation.content, isRegen: true)
            } else {
                await edit(conversation: conversation, editedContent: conversation.content)
            }
        }
    }
    
    @MainActor
    func edit() async {
        if editingIndex <= resetMarker {
            removeResetContextMarker()
        }

        removeConversations(from: editingIndex)
        let text = self.editingMessage
    
        await send(text: text, isEdit: true)
    }
    
    func setupEditing(conversation: Conversation) {
        withAnimation {
            isEditing = true
            editingIndex = conversations.firstIndex { $0.id == conversation.id }!
            editingMessage = conversation.content
            editingAudioPath = conversation.audioPath
            editingPDFPath = conversation.pdfPath
            for imagePath in conversation.imagePaths {
                editingImages.append(imagePath)
            }
        }
    }
    
    func resetIsEditing() {
        withAnimation {
            isEditing = false
            editingIndex = -1
            editingMessage = ""
            editingImages = []
            editingAudioPath = ""
            editingPDFPath = ""
        }
    }

    @MainActor
    func edit(conversation: Conversation, editedContent: String) async {
        if let index = conversations.firstIndex(of: conversation) {
            if index <= resetMarker {
                removeResetContextMarker()
            }

            for imagePath in conversation.imagePaths {
                inputImages.append(imagePath)
            }
            
            if !conversation.audioPath.isEmpty {
                inputAudioPath = conversation.audioPath
            }
            
            if !conversation.pdfPath.isEmpty {
                inputPDFPath = conversation.pdfPath
            }
            
            removeConversations(from: index)
            await send(text: editedContent)
        }
    }
    
    @MainActor
    private func send(text: String, isRegen: Bool = false, isRetry: Bool = false, isEdit: Bool = false) async {
        streamingTask?.cancel()
        
        if isEdit {
            inputImages = editingImages
            inputAudioPath = editingAudioPath
            inputPDFPath = editingPDFPath
        }
        
        resetErrorDesc()

        if !isRegen && !isRetry {
            let imagePaths = Array(inputImages)
       
            appendConversation(Conversation(role: .user, content: text, imagePaths: imagePaths, audioPath: inputAudioPath, pdfPath: inputPDFPath))
        }
        
        if isEdit {
            resetIsEditing()
        }
        
        streamingTask = Task(priority: .userInitiated) {
            try await processRequest()
        }
        
        do {
            inputImages = []
            inputAudioPath = ""
            inputPDFPath = ""
            
            #if os(macOS)
            try await streamingTask?.value
            #else
            let application = UIApplication.shared
            let taskId = application.beginBackgroundTask {
                // Handle expiration of background task here
            }
            
            try await streamingTask?.value
            
            application.endBackgroundTask(taskId)
            #endif
            
        } catch {
            if let lastConversation = conversations.last, lastConversation.role == .assistant, lastConversation.content == "" {
                removeConversation(at: conversations.count - 1)
            }
            
            conversations[conversations.count - 1].isReplying = false
            setErrorDesc(errorDesc: error.localizedDescription)
        }


        save()
    }
    
    @MainActor
    func createChatQuery() -> ChatQuery {
        var mutableConversations = adjustedConversations
        if mutableConversations.last?.role == .assistant {
            mutableConversations = mutableConversations.dropLast()
        }
        
        var finalMessages = mutableConversations.map({ conversation in
            return conversation.toChat()
        })

        
        let finalSysPrompt = {
            self.configuration.systemPrompt
        }
        
        let systemPrompt = Conversation(role: .system, content: finalSysPrompt())
        
        if !systemPrompt.content.isEmpty {
            finalMessages.insert(systemPrompt.toChat(), at: 0)
        }
        
  
        return ChatQuery(messages: finalMessages,
                         model: configuration.model.id,
                         maxTokens: 4000,
                         temperature: configuration.temperature)
        
    }
    
    @MainActor
    func processRequest() async throws {
        let lastConversationData = appendConversation(Conversation(role: .assistant, content: "", isReplying: true))
        
        let service = OpenAI(configuration: configuration.provider.config)
        
        let query = createChatQuery()
        
        Task {
            await generateTitle(forced: false)
        }
        
        let uiUpdateInterval = TimeInterval(0.1)

        var lastUIUpdateTime = Date()
        
        var streamText = ""
        
        for try await result in service.chatsStream(query: query) {
        
                streamText += result.choices.first?.delta.content ?? ""
                
                let currentTime = Date()
                if currentTime.timeIntervalSince(lastUIUpdateTime) >= uiUpdateInterval {
                    conversations[conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                    lastConversationData.sync(with: conversations[conversations.count - 1])
                    lastUIUpdateTime = currentTime
                }
        
        }

       
        if !streamText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.conversations[self.conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                lastConversationData.sync(with: self.conversations[self.conversations.count - 1])
                self.conversations[self.conversations.count - 1].isReplying = false
            }
        }
    }
}

extension DialogueSession {
    convenience init?(rawData: DialogueData) {
        self.init()
        guard let id = rawData.id,
              let date = rawData.date,
              let title = rawData.title,
              let errorDesc = rawData.errorDesc,
              let configurationData = rawData.configuration,
              let conversations = rawData.conversations as? Set<ConversationData> else {
            return nil
        }
        let resetMarker = rawData.resetMarker
        let isArchive = rawData.isArchive

        self.rawData = rawData
        self.id = id
        self.date = date
        self.title = title
        self.errorDesc = errorDesc
        self.isArchive = isArchive
        self.resetMarker = Int(resetMarker)
        
        if let configuration = try? JSONDecoder().decode(Configuration.self, from: configurationData) {
            self.configuration = configuration
        }

        self.conversations = conversations.compactMap { data in
            if let id = data.id,
               let content = data.content,
               let role = data.role,
               let date = data.date,
               let audioPath = data.audioPath,
               let pdfPath = data.pdfPath,
               let toolRawValue = data.toolRawValue,
               let arguments = data.arguments,
               let imagePaths = data.imagePaths {
                let imagePaths = imagePaths.split(separator: "|||").map(String.init) // Convert back to an array of strings
                let conversation = Conversation(
                  id: id,
                  date: date,
                  role: ConversationRole(rawValue: role) ?? .assistant,
                  content: content,
                  imagePaths: imagePaths,
                  audioPath: audioPath,
                  pdfPath: pdfPath,
                  toolRawValue: toolRawValue,
                  arguments: arguments
                )
                return conversation
            } else {
                return nil
            }
        }

        self.conversations.sort {
            $0.date < $1.date
        }
    }

    @discardableResult
    func appendConversation(_ conversation: Conversation) -> ConversationData {
        if conversations.isEmpty {
            removeResetContextMarker()
        }

//        withAnimation {
            conversations.append(conversation)
//        }
        isAddingConversation.toggle()
        
        let data = Conversation.createConversationData(from: conversation, in: PersistenceController.shared.container.viewContext)
        
        rawData?.conversations?.adding(data)
        data.dialogue = rawData

        do {
            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }

        return data
    }

    func removeConversation(at index: Int) {
        if self.isReplying {
            return
        }
        
        let conversation = conversations[index]
        
        if conversations.count <= 2 {
            let _ = conversations.remove(at: index)
        } else {
            withAnimation {
                let _ = conversations.remove(at: index)
            }
        }

        if resetMarker == index {
            if conversations.count > 1 {
                resetMarker = index - 1
            } else {
                resetMarker = -1
            }
        }

        do {
            if let conversationsSet = rawData?.conversations as? Set<ConversationData>,
               let conversationData = conversationsSet.first(where: {
                   $0.id == conversation.id
               }) {
                PersistenceController.shared.container.viewContext.delete(conversationData)
            }
            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }

//    @MainActor
    func removeConversation(_ conversation: Conversation) {
        guard let index = conversations.firstIndex(where: { $0.id == conversation.id }) else {
            return
        }

        withAnimation {
            removeConversation(at: index)
        }

        if conversations.isEmpty {
            resetErrorDesc()
        }
    }

    func removeConversations(from index: Int) {
        guard index < conversations.count else {
            print("Index out of range")
            return
        }

        let conversationsToRemove = Array(conversations[index...])
        let idsToRemove = conversationsToRemove.map { $0.id }

        do {
            if let conversationsSet = rawData?.conversations as? Set<ConversationData> {
                let conversationsDataToRemove = conversationsSet.filter { idsToRemove.contains($0.id!) }
                for conversationData in conversationsDataToRemove {
                    PersistenceController.shared.container.viewContext.delete(conversationData)
                }
            }
            try PersistenceController.shared.save()
            conversations.removeSubrange(index...)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func removeAllConversations() {
        removeResetContextMarker()
        resetErrorDesc()
        
        withAnimation {
            conversations.removeAll()
        }

        do {
            let viewContext = PersistenceController.shared.container.viewContext
            if let conversations = rawData?.conversations as? Set<ConversationData> {
                conversations.forEach(viewContext.delete)
            }
            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func setErrorDesc(errorDesc: String) {
        self.errorDesc = errorDesc
        save()
    }

    func resetErrorDesc() {
        errorDesc = ""
        save()
    }

    func save() {
        do {
            rawData?.date = date
            rawData?.title = title
            rawData?.errorDesc = errorDesc
            rawData?.isArchive = isArchive
            rawData?.resetMarker = Int16(resetMarker)
        
            rawData?.configuration = try JSONEncoder().encode(configuration)

            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

#if os(macOS)
extension DialogueSession {
    public func exportToMd() -> String? {
        let markdownContent = generateMarkdown(for: conversations)

        let uniqueTimestamp = Int(Date().timeIntervalSince1970)
        // Specify the file path
        let filePath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads/\(title)_\(uniqueTimestamp).md")

        // Write the content to the file
        do {
            try markdownContent.write(to: filePath, atomically: true, encoding: .utf8)
            return filePath.lastPathComponent
        } catch {
            return nil
        }

    }
    
    // Function to generate Markdown content
    private func generateMarkdown(for conversations: [Conversation]) -> String {
        var markdown = "# Conversations\n\n"
        
        for conversation in conversations {
            markdown += "### \(conversation.role.rawValue.capitalized)\n"
            markdown += "\(conversation.content)\n\n"
        }
        
        return markdown
    }

}
#endif
