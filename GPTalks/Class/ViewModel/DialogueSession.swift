//
//  DialogueSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI
import OpenAI

class DialogueSession: ObservableObject, Identifiable, Equatable, Hashable, Codable {
    
    struct Configuration: Codable {
        var temperature: Double
        var systemPrompt: String
        var contextLength: Int
        var provider: Provider
        var model: Model
        var ignoreWeb: String
        var gpt4freeProvider: GPT4FreeProvider
        
        init() {
            provider = AppConfiguration.shared.preferredChatService
            contextLength = AppConfiguration.shared.contextLength
            temperature = AppConfiguration.shared.temperature
            systemPrompt = AppConfiguration.shared.systemPrompt
            model = provider.preferredModel
            ignoreWeb = AppConfiguration.shared.ignoreWeb
            gpt4freeProvider = AppConfiguration.shared.Gprovider
        }
        
    }
    
    //MARK: - Codable
    
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
    
    //MARK: - Hashable, Equatable

    static func == (lhs: DialogueSession, rhs: DialogueSession) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    var rawData: DialogueData?
    
    //MARK: - State

    @Published var input: String = ""
    @Published var title: String = "New Chat"
    @Published var conversations: [Conversation] = []
    @Published var date = Date()
    @Published var errorDesc: String = ""
    @Published var configuration: Configuration = Configuration()
    
    private var initFinished = false
    //MARK: - Properties
        
    var lastMessage: String {
        if errorDesc != "" {
            return errorDesc
        }
        return conversations.last?.content ?? ""
    }
    
    var lastConversation: Conversation {
        return conversations[conversations.count - 1]
    }
    
    var lastConcersationContent: String? {
        return lastConversation.content
    }
    
//    var lastConversationData: ConversationData?
    
    var streamingTask: Task<Void, Error>?
    
    
    func isReplying() -> Bool {
        return !conversations.isEmpty && lastConversation.isReplying
    }
    
    init() {
        
    }
    
    //MARK: - Message Actions
    @MainActor
    func stopStreaming() {
        streamingTask?.cancel()
        streamingTask = nil
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
    func clearMessages() {
        withAnimation { [weak self] in
            self?.removeAllConversations()
        }
    }
    
    @MainActor
    func regenerate(from index: Int) async {
        removeConversations(from: index)
        await send(text: lastConversation.content, isRegen: true)
    }
    
    @MainActor
    func edit(from index: Int, conversation: Conversation) async {
        removeConversations(from: index)
        await send(text: conversation.content)
    }
    
    @MainActor
    func retry() async {
        await send(text: lastConversation.content, isRetry: true)
    }
    
    #if os(iOS)
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    func endStreamingTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    #endif
    
    @MainActor
    private func send(text: String, isRegen: Bool = false, isRetry: Bool = false) async {

        
        if isReplying() {
            return
        }
        resetErrorDesc()
        
        var streamText = ""
        
        if !isRegen && !isRetry{
            appendConversation(Conversation(role: "user", content: text))
        }
        
        let openAIconfig = configuration.provider.config
        let service: OpenAI = OpenAI(configuration: openAIconfig)
        
        var query = ChatQuery(model: configuration.model.id,
                              messages: ([Conversation(role: "system", content: configuration.systemPrompt)] + Array(conversations.suffix(configuration.contextLength - 1))).map({ conversation in
                                  conversation.toChat()
                              }),
                              temperature: configuration.temperature,
                              maxTokens: configuration.model.maxTokens,
                              stream: true)
        
        if configuration.provider == .gpt4free {
            query.model = configuration.model.id
//            query.provider = AppConfiguration.shared.Gprovider.name
//            query.ignore_web = AppConfiguration.shared.ignoreWeb
            query.provider = configuration.gpt4freeProvider.name
            query.ignore_web = configuration.ignoreWeb
        }
        
        #if os(iOS)
        // Start the background task when the streaming task starts
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "MyStreamingTask") {
            // This block is called when the background time is about to expire
            // End the task if it's still running
            self.endStreamingTask()
        }
        #endif
        
        let lastConversationData = appendConversation(Conversation(role: "assistant", content: "", isReplying: true))
        
        streamingTask = Task {
            for try await result in service.chatsStream(query: query) {
                streamText += result.choices.first?.delta.content ?? ""
                conversations[conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
            }
#if os(iOS)
            endStreamingTask()
#endif
        }
        
        do {
            try await streamingTask?.value
            
            lastConversationData.sync(with: conversations[conversations.count - 1])
            
        }catch {
            // TODO: do better with stop_reason from openai
            if error.localizedDescription == "cancelled" {
                if lastConversation.content != "" {
                    lastConversationData.sync(with: conversations[conversations.count - 1])
                } else {
                    removeConversation(at: conversations.count - 1)
                }
                conversations[conversations.count - 1].isReplying = false
                return
            }
            removeConversation(at: conversations.count - 1)
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
        self.rawData = rawData
        self.id = id
        self.date = date
        self.title = title
        self.errorDesc = errorDesc
        if let configuration = try? JSONDecoder().decode(Configuration.self, from: configurationData) {
            self.configuration = configuration
        }
        
        self.conversations = conversations.compactMap { data in
            if let id = data.id,
               let content = data.content,
               let role = data.role,
               let date = data.date {
                let conversation = Conversation(
                    id: id,
                    date: date,
                    role: role,
                    content: content
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
        // TODO: animation
        conversations.append(conversation)
        
        let data = ConversationData(context: PersistenceController.shared.container.viewContext)
        data.id = conversation.id
        data.date = conversation.date
        data.role = conversation.role
        data.content = conversation.content
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
        let conversation = conversations.remove(at: index)
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
        conversations.removeAll()
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
        self.errorDesc = ""
        save()
    }
    
    func save() {
        guard initFinished else {
            return
        }
        do {
            rawData?.date = date
            rawData?.title = title
            rawData?.errorDesc = errorDesc
            rawData?.configuration = try JSONEncoder().encode(configuration)
    
            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
