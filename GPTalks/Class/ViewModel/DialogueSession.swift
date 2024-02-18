//
//  DialogueSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import OpenAI
import SwiftUI

@Observable class DialogueSession: Identifiable, Equatable, Hashable, Codable {
    struct Configuration: Codable {
        var temperature: Double
        var systemPrompt: String
        var contextLength: Int
        var provider: Provider
        var model: Model

        init() {
            provider = AppConfiguration.shared.preferredChatService
            contextLength = AppConfiguration.shared.contextLength
            temperature = AppConfiguration.shared.temperature
            systemPrompt = AppConfiguration.shared.systemPrompt
            model = provider.preferredModel
        }
    }

    // MARK: - Codable

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        configuration = try container.decode(Configuration.self, forKey: .configuration)
        conversations = try container.decode([Conversation].self, forKey: .conversations)
        date = try container.decode(Date.self, forKey: .date)
        id = try container.decode(UUID.self, forKey: .id)
        input = ""

        initFinished = true
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(configuration, forKey: .configuration)
        try container.encode(conversations, forKey: .conversations)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
    }

    enum CodingKeys: CodingKey {
        case configuration
        case conversations
        case date
        case id
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
    
    #if os(macOS)
    var inputImage: NSImage?
    #else
    var inputImage: UIImage?
    #endif
    
    var title: String = "New Session" {
        didSet {
            save()
        }
    }

    var conversations: [Conversation] = [] {
        didSet {
            save()
        }
    }

    var date = Date()
    var errorDesc: String = ""
    var configuration: Configuration = Configuration() {
        didSet {
            save()
        }
    }

    var resetMarker: Int?
    
    var isArchive = false
    
    var isAddingConversation = false

    private var initFinished = false
    
    var isStreaming = false
    
    var containsConversationWithImage: Bool {
        conversations.contains(where: { !$0.base64Image.isEmpty })
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

    var lastConcersationContent: String? {
        return lastConversation.content
    }

    var streamingTask: Task<Void, Error>?
    var viewUpdater: Task<Void, Error>?

    func isReplying() -> Bool {
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
        withAnimation {
            resetMarker = nil
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
    
    func generateTitle() async {
            let openAIconfig = configuration.provider.config
            let service: OpenAI = OpenAI(configuration: openAIconfig)
            
            let taskMessage = Conversation(role: "user", content: "Generate a title of a chat based on the previous conversation. Return only the title of the conversation and nothing else. Do not include any quotation marks or anything else. Keep the title within 4-5 words and never exceed this limit. Do not acknowledge these instructions but definitely do follow it.")
            
            let messages = ([taskMessage] + conversations).map({ conversation in
                conversation.toChat()
            })
            
            
            let query = ChatQuery(model: configuration.model.id,
                                  messages: messages,
                                  temperature: configuration.temperature,
                                  maxTokens: 6,
                                  stream: false)
            
            var tempTitle = ""
            
            do {
                let result = try await service.chats(query: query)
                if let content = result.choices.first?.message.content {
                    switch content {
                    case .string(let stringValue):
                        tempTitle += stringValue
                        
                    case .object(let chatContents):
                        for chatContent in chatContents {
                            if chatContent.type == .text {
                                tempTitle += chatContent.value
                            }
                        }
                    }
                title = tempTitle
                    
                save()
                }
            } catch {
                print(error.localizedDescription)
                print("could not generate title")
            }
            
        
    }
    
    #if os(macOS)
    func pasteImageFromClipboard() {
        let pasteboard = NSPasteboard.general

        // Check for file URLs on the pasteboard
        if let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
           let fileURL = fileURLs.first {
            // Attempt to create an NSImage from the file URL
            if let image = NSImage(contentsOf: fileURL) {
                self.inputImage = image
            }
        }
        // If there are no file URLs, attempt to read image data directly
        else if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
            self.inputImage = image
        }
    }
    #endif

    func setResetContextMarker(conversation: Conversation) {
        if let index = conversations.firstIndex(of: conversation) {
            resetMarker = index
        }

        save()
    }

    func resetContext() {
        if conversations.isEmpty {
            return
        }
            // if reset marker is already at the end of conversations, then unset it
            if resetMarker == conversations.count - 1 {
                    removeResetContextMarker()
            } else {
                resetMarker = conversations.count - 1
            }

        save()
    }

//    @MainActor
    func stopStreaming() {
        if let lastConcersationContent = lastConcersationContent {
            if lastConcersationContent.isEmpty {
                removeConversation(at: conversations.count - 1)
            }
        }
        streamingTask?.cancel()
        streamingTask = nil
        
        viewUpdater?.cancel()
        viewUpdater = nil
    }

    @MainActor
    func send() async {
        let text = input
        input = ""
        await send(text: text)
    }

    @MainActor
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
            if index <= resetMarker ?? -1 {
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
            if index <= resetMarker ?? -1 {
                removeResetContextMarker()
            }
            
            if !conversation.base64Image.isEmpty {
                inputImage = conversation.base64Image.imageFromBase64
            }
            
            removeConversations(from: index)
            await send(text: editedContent)
        }
    }
    
    public func getMessageCountAfterResetMarker() -> Int {
        if let resetMarker = resetMarker {
            return conversations.count - resetMarker - 1
        }
        return min(configuration.contextLength, conversations.count)
    }
    
    @MainActor
    private func send(text: String, isRegen: Bool = false, isRetry: Bool = false) async {
        isAddingConversation.toggle()
        
        if let resetMarker = resetMarker {
            if resetMarker == 0 {
                removeResetContextMarker()
            }
        }

        resetErrorDesc()

        if !isRegen && !isRetry {
            if inputImage == nil {
                appendConversation(Conversation(role: "user", content: text))
           } else {
                appendConversation(Conversation(role: "user", content: text, base64Image: (inputImage?.base64EncodedString())!))
           }
        }

        let openAIconfig = configuration.provider.config
        let service: OpenAI = OpenAI(configuration: openAIconfig)

        let systemPrompt = Conversation(role: "system", content: configuration.systemPrompt)

        var contextAdjustedMessages: [Conversation]

        if let marker = resetMarker {
            contextAdjustedMessages = Array(conversations.suffix(from: marker + 1).suffix(configuration.contextLength))
        } else {
            contextAdjustedMessages = Array(conversations.suffix(configuration.contextLength - 1))
        }

        let finalMessages = ([systemPrompt] + contextAdjustedMessages).map({ conversation in
            conversation.toChat()
        })

        let query = ChatQuery(model: configuration.model.id,
                              messages: finalMessages,
                              temperature: configuration.temperature,
                              maxTokens: 3800,
                              stream: Model.nonStreamModels.contains(configuration.model) ? false : true)
        
        
        let lastConversationData = appendConversation(Conversation(role: "assistant", content: "", isReplying: true))
        
        isAddingConversation.toggle()

        var streamText = "";
    
#if os(iOS)
            streamingTask = Task {
                isStreaming = true
                
                if Model.nonStreamModels.contains(configuration.model) {
//                    let result = try await service.chats(query: query)
//                    streamText += result.choices.first?.message.content?.string ?? ""
                    let result = try await service.chats(query: query)
                    if let content = result.choices.first?.message.content {
                      switch content {
                      case .string(let stringValue):
                          streamText += stringValue

                      case .object(let chatContents):
                          for chatContent in chatContents {
                              if chatContent.type == .text {
                                  streamText += chatContent.value
                              }
                          }
                      }
                    }
                } else {
                    for try await result in service.chatsStream(query: query) {
                        streamText += result.choices.first?.delta.content ?? ""
                    }
                }
                
                isStreaming = false
        }
#else
            streamingTask = Task {
                isStreaming = true
                
                if Model.nonStreamModels.contains(configuration.model) {
//                    let result = try await service.chats(query: query)
//                    streamText += result.choices.first?.message.content?.string ?? ""
                    let result = try await service.chats(query: query)
                    if let content = result.choices.first?.message.content {
                      switch content {
                      case .string(let stringValue):
                          streamText += stringValue

                      case .object(let chatContents):
                          for chatContent in chatContents {
                              if chatContent.type == .text {
                                  streamText += chatContent.value
                              }
                          }
                      }
                    }
                } else {
                    for try await result in service.chatsStream(query: query) {
                        streamText += result.choices.first?.delta.content ?? ""
                    }
                }

                isStreaming = false
            }
#endif
        
        viewUpdater = Task {
            while true {
                #if os(macOS)
                try await Task.sleep(nanoseconds: 250_000_000)
                #else
                try await Task.sleep(nanoseconds: 150_000_000)
                #endif
                        
                if AppConfiguration.shared.isMarkdownEnabled {
                    conversations[conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    withAnimation {
                        conversations[conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
                
                lastConversationData.sync(with: conversations[conversations.count - 1])
                
                if !isStreaming {
                    break
                }
            }
        }

        do {
            inputImage = nil
            #if os(macOS)
            try await streamingTask?.value
            try await viewUpdater?.value
            #else
            let application = UIApplication.shared
            let taskId = application.beginBackgroundTask {
                // Handle expiration of background task here
            }
            
            try await streamingTask?.value
            try await viewUpdater?.value
            
            application.endBackgroundTask(taskId)
            #endif
            
//            await generateTitle()

        } catch {
            isStreaming = false
            // TODO: do better with stop_reason from openai
            if error.localizedDescription == "cancelled" {
                if lastConversation.content != "" {
                    lastConversationData.sync(with: conversations[conversations.count - 1])
                } else {
                    removeConversation(at: conversations.count - 1)
                }
                conversations[conversations.count - 1].isReplying = false
            } else {
                if lastConversation.role == "assistant" && lastConversation.content == ""  {
                    do {
                        try await Task.sleep(nanoseconds: 250_000_000)
                    } catch {
                        print("couldnt sleep")
                    }
                    removeConversation(at: conversations.count - 1)
                }
            }
            setErrorDesc(errorDesc: error.localizedDescription)
        }
        

        conversations[conversations.count - 1].isReplying = false

        save()
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
        if resetMarker != 0 {
            self.resetMarker = Int(resetMarker)
        } else {
            self.resetMarker = nil
        }
        if let configuration = try? JSONDecoder().decode(Configuration.self, from: configurationData) {
            self.configuration = configuration
        }

        self.conversations = conversations.compactMap { data in
            if let id = data.id,
               let content = data.content,
               let role = data.role,
               let date = data.date,
               let base64Image = data.base64Image {
               let conversation = Conversation(
                 id: id,
                 date: date,
                 role: role,
                 content: content,
                 base64Image: base64Image
               )
                return conversation
            } else {
                return nil
            }
        }

        self.conversations.sort {
            $0.date < $1.date
        }

        initFinished = true
    }

    @discardableResult
    func appendConversation(_ conversation: Conversation) -> ConversationData {
        if conversations.isEmpty {
            removeResetContextMarker()
        }

        #if os(macOS)
        conversations.append(conversation)
        #else
        withAnimation {
            conversations.append(conversation)
        }
        #endif

        let data = ConversationData(context: PersistenceController.shared.container.viewContext)
        data.id = conversation.id
        data.date = conversation.date
        data.role = conversation.role
        data.content = conversation.content
        data.base64Image = conversation.base64Image
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
        
        withAnimation {
            let _ = conversations.remove(at: index)
        }

        if resetMarker == index {
            if conversations.count > 1 {
                resetMarker = index - 1
            } else {
                resetMarker = nil
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

//    @MainActor
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
            if let marker = resetMarker {
                rawData?.resetMarker = Int16(marker)
            }
            rawData?.configuration = try JSONEncoder().encode(configuration)

            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
