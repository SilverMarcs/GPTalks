//
//  DialogueSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI
import PDFKit
import OpenAI

#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

@Observable class DialogueSession: Identifiable, Equatable, Hashable {
    struct Configuration: Codable {
        var temperature: Double
        var systemPrompt: String
        var provider: Provider
        var model: Model

        init() {
            provider = AppConfiguration.shared.preferredChatService
            temperature = AppConfiguration.shared.temperature
            systemPrompt = AppConfiguration.shared.systemPrompt
            model = provider.preferredChatModel
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
    var inputImages: [PlatformImage] = []
    var inputAudioPath: String = ""
    
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
        // Context adjustment logic
        let adjustedConversations: [Conversation]
        if conversations.count > resetMarker + 1 {
            adjustedConversations = Array(conversations.suffix(from: resetMarker + 1))
        } else {
            adjustedConversations = conversations
        }
        
        // Filtering on adjusted conversations
        return adjustedConversations.contains(where: { $0.role == "user" && !$0.imagePaths.isEmpty }) || inputImages.count > 0
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

    // MARK: - Message Actions
    
    func toggleArchive() {
        isArchive.toggle()
        save()
    }

    func removeResetContextMarker() {
//        withAnimation {
            resetMarker = -1
//        }
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
        if conversations.count == 1 || conversations.count == 2 || (forced && conversations.count >= 2) && title == "New Session" {
            let openAIconfig = configuration.provider.config
            let service: OpenAI = OpenAI(configuration: openAIconfig)
            
            let taskMessage = Conversation(role: "user", content: "Generate a title of a chat based on the previous conversation. Return only the title of the conversation and nothing else. Do not include any quotation marks or anything else. Keep the title within 4-5 words and never exceed this limit. If there are two distinct topics being talked about, just make a title with two words and an and word in the middle. If the conversation discusses multiple things not linked to each other, come up with a title that decribes the most recent discussion and add the two words and more to the end. Do not acknowledge these instructions but definitely do follow them. Again, do not put the title in quoation marks. Do not put any punctuation at all")
            
            let messages = (conversations + [taskMessage]).map({ conversation in
                conversation.toChat()
            })
            
            let query = ChatQuery(messages: messages,
                                  model: Model.gpt3t.id,
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
            self.inputImages.append(image)
        }
    }
    #endif

    func setResetContextMarker(conversation: Conversation) {
        if let index = conversations.firstIndex(of: conversation) {
//            withAnimation {
                resetMarker = index
//            }
        }

        save()
    }

    func resetContext() {
        if conversations.isEmpty {
            return
        }
            if resetMarker == conversations.count - 1 {
                    removeResetContextMarker()
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

        if conversations[conversations.count - 1].role != "user" {
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
            
            if conversations[index].role == "assistant" {
                removeConversations(from: index)
                await send(text: lastConversation.content, isRegen: true)
            } else {
                await edit(conversation: conversation, editedContent: conversation.content)
            }
        }
    }

    @MainActor
    func edit(conversation: Conversation, editedContent: String) async {
        if let index = conversations.firstIndex(of: conversation) {
            if index <= resetMarker {
                removeResetContextMarker()
            }
            
            for imagePath in conversation.imagePaths {
                if let imageData = getSavedImage(fromPath: imagePath) {
                    inputImages.append(imageData)
                }
            }
            
            if !conversation.audioPath.isEmpty {
                inputAudioPath = conversation.audioPath
            }
            
            removeConversations(from: index)
            await send(text: editedContent)
        }
    }
    
  
    func filteredConversations() -> [Conversation] {
        return conversations.filter { $0.role != "ss" }
    }
    
    @MainActor
    private func send(text: String, isRegen: Bool = false, isRetry: Bool = false) async {
        resetErrorDesc()

        if !isRegen && !isRetry {
            if inputImages.isEmpty {
                if inputAudioPath.isEmpty {
                    appendConversation(Conversation(role: "user", content: text))
                } else {
                    appendConversation(Conversation(role: "user", content: text, audioPath: inputAudioPath))
                }
           } else {
               var imagePaths: [String] = []
               
               for inputImage in inputImages {
                   if let savedURL = saveImage(image: inputImage) {
                       imagePaths.append(savedURL)
                   }
               }
               
               appendConversation(Conversation(role: "user", content: text, imagePaths: imagePaths))
           }
        }
        
        streamingTask = Task(priority: .userInitiated) {
            try await processRequest()
        }
        
        do {
            inputImages = []
            inputAudioPath = ""
            
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
            if let lastConversation = conversations.last, lastConversation.role == "assistant", lastConversation.content == "" {
                removeConversation(at: conversations.count - 1)
            }
            
            conversations[conversations.count - 1].isReplying = false
            setErrorDesc(errorDesc: error.localizedDescription)
        }


        save()
    }
    
    @MainActor
    func createChatQuery() -> ChatQuery {
        var adjustedConversations: [Conversation] = conversations
        
        // Adjusting the conversations array based on the resetMarker
        if conversations.count > resetMarker + 1 {
            adjustedConversations = Array(conversations.suffix(from: resetMarker + 1))
        }
        
        if adjustedConversations.last?.role == "assistant" {
            adjustedConversations = adjustedConversations.dropLast() // dropping the emtpy last conversation cuz its the empty assistant reply
        }
        
        var finalMessages = adjustedConversations.map({ conversation in
            conversation.toChat()
        })

        let systemPrompt = Conversation(role: "system", content: configuration.systemPrompt)
        if !systemPrompt.content.isEmpty {
            finalMessages.insert(systemPrompt.toChat(), at: 0)
        }
        
        if configuration.model == .gpt4vision {
            return ChatQuery(messages: finalMessages,
                             model: configuration.model.id,
                             maxTokens: 4000,
                             temperature: configuration.temperature)
        } else {
            return ChatQuery(messages: finalMessages,
                             model: configuration.model.id,
                             maxTokens: 4000,
                             temperature: configuration.temperature,
                             tools: ChatTool.allTools)
        }
    }
    
    @MainActor
    func processRequest() async throws {
        let lastConversationData = appendConversation(Conversation(role: "assistant", content: "", isReplying: true))
        
        let service = OpenAI(configuration: configuration.provider.config)
        
        let query = createChatQuery()
        
        if AppConfiguration.shared.isAutoGenerateTitle {
            if ![Model.gpt4vision, Model.customVision].contains(configuration.model) {
                Task {
                    await generateTitle(forced: false)
                }
            }
        }
         
        let uiUpdateInterval = TimeInterval(0.05)

        var lastUIUpdateTime = Date()
        
        var streamText = ""
        var funcParam = ""
        var chatTool: ChatTool?
        
        for try await result in service.chatsStream(query: query) {
            if let funcCalls = result.choices.first?.delta.toolCalls, let firstFuncCall = funcCalls.first {
                let toolName = firstFuncCall.function?.name ?? ""
                let _ = firstFuncCall.id ?? ""

                if chatTool == nil {
                    chatTool = ChatTool(rawValue: toolName)
                }
                
                funcParam += funcCalls.first?.function?.arguments ?? ""
            } else {
                streamText += result.choices.first?.delta.content ?? ""
                
                let currentTime = Date()
                if currentTime.timeIntervalSince(lastUIUpdateTime) >= uiUpdateInterval {
                    conversations[conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                    lastConversationData.sync(with: conversations[conversations.count - 1])
                    lastUIUpdateTime = currentTime
                }
            }
        }

        if let chatTool = chatTool {
            switch chatTool {
            case .urlScrape, .googleSearch, .imageGenerate, .transcribe:
        
                conversations[conversations.count - 1].toolRawValue = chatTool.rawValue
                conversations[conversations.count - 1].arguments = funcParam
                conversations[conversations.count - 1].isReplying = false
                
                lastConversationData.sync(with: conversations[conversations.count - 1])
                
                try await handleToolCall(chatTool: chatTool, funcParam: funcParam)
            }
        } else {
            if !streamText.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.conversations[self.conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                    lastConversationData.sync(with: self.conversations[self.conversations.count - 1])
                    self.conversations[self.conversations.count - 1].isReplying = false
                }
            }
        }
    }

    @MainActor
    func handleToolCall(chatTool: ChatTool, funcParam: String) async throws {
        switch chatTool {
        case .urlScrape:
            if let url = extractValue(from: funcParam, forKey: chatTool.paramName) {
                let lastToolCall = appendConversation(Conversation(role: "tool", content: "", toolRawValue: chatTool.rawValue, isReplying: true))
                
                let webContent: String
                
                if AppConfiguration.shared.useExperimentalWebScraper {
                    webContent = try await retrieveWebContent(from: url)
                } else {
                    webContent = try await fetchAndParseHTMLAsync(from: url)
                }
                
                conversations[conversations.count - 1].content = webContent
                lastToolCall.sync(with: conversations[conversations.count - 1])
                conversations[conversations.count - 1].isReplying = false
                
                try await processRequest()
            }
        case .googleSearch:
            if let searchQuery = extractValue(from: funcParam, forKey: chatTool.paramName) {
                
                let lastToolCall = appendConversation(Conversation(role: "tool", content: "", toolRawValue: chatTool.rawValue, isReplying: true))
                let searchResult = try await GoogleSearchService().performSearch(query: searchQuery)
                
                conversations[conversations.count - 1].content = searchResult
                lastToolCall.sync(with: conversations[conversations.count - 1])
                conversations[conversations.count - 1].isReplying = false
                
                try await processRequest()
            }
        case .transcribe:
            let service = OpenAI(configuration: AppConfiguration.shared.transcriptionProvider.config)
            
            if let audioPath = extractValue(from: funcParam, forKey: chatTool.paramName) {
                let query = try AudioTranscriptionQuery(file: Data(contentsOf: URL(string: audioPath)!), fileType: .mp3, model: AppConfiguration.shared.transcriptionModel.id)
                
                let lastToolCall = appendConversation(Conversation(role: "tool", content: "", toolRawValue: chatTool.rawValue, isReplying: true))
                let result = try await service.audioTranscriptions(query: query)
                
                conversations[conversations.count - 1].content = result.text
                lastToolCall.sync(with: conversations[conversations.count - 1])
                conversations[conversations.count - 1].isReplying = false

                try await processRequest()
            }
        case .imageGenerate:
            let service = OpenAI(configuration: AppConfiguration.shared.imageProvider.config)
            
            if let prompt = extractValue(from: funcParam, forKey: chatTool.paramName) {
                let query = ImagesQuery(prompt: prompt, model: AppConfiguration.shared.imageModel.id, n: 1, quality: .hd, size: ._1024)
                
                let lastToolCall = appendConversation(Conversation(role: "tool", content: "", toolRawValue: chatTool.rawValue, isReplying: true))
                let results = try await service.images(query: query)
                conversations[conversations.count - 1].content = "Provider: " + AppConfiguration.shared.imageProvider.name + "\n" + "Model: " + AppConfiguration.shared.imageModel.name
                lastToolCall.sync(with: conversations[conversations.count - 1])
                
                for urlResult in results.data {
                    if let urlString = urlResult.url, let url = URL(string: urlString) {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let savedURL = saveImage(image: PlatformImage(data: data)!) {
                            conversations[conversations.count - 1].isReplying = false
                            appendConversation(Conversation(role: "assistant", content: "Here is the image you requested:", imagePaths: [savedURL]))
                        }
                    }
                }
                
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
               let toolRawValue = data.toolRawValue,
               let arguments = data.arguments,
               let imagePaths = data.imagePaths {
                let imagePaths = imagePaths.split(separator: "|||").map(String.init) // Convert back to an array of strings
                let conversation = Conversation(
                  id: id,
                  date: date,
                  role: role,
                  content: content,
                  imagePaths: imagePaths,
                  audioPath: audioPath,
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

        conversations.append(conversation)

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
        let conversation = conversations[index]
        
        if conversations.count <= 2 {
            let _ = conversations.remove(at: index)
        } else {
//            withAnimation {
                let _ = conversations.remove(at: index)
//            }
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

        removeConversation(at: index)

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
