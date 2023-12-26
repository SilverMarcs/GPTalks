//
//  DialogueSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import OpenAI
import SwiftUI

class DialogueSession: ObservableObject, Identifiable, Equatable, Hashable, Codable {
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

    @Published var input: String = ""
    @Published var title: String = "New Chat" {
        didSet {
            save()
        }
    }

    @Published var conversations: [Conversation] = [] {
        didSet {
            save()
        }
    }

    @Published var date = Date()
    @Published var errorDesc: String = ""
    @Published var configuration: Configuration = Configuration() {
        didSet {
            save()
        }
    }

    @Published var resetMarker: Int?
    
    @Published var isArchive = false

    private var initFinished = false

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

    func isReplying() -> Bool {
        return !conversations.isEmpty && lastConversation.isReplying
    }

    init() {
    }

    // MARK: - Message Actions
    
    func toggleArchive() {
        isArchive.toggle()
        save()
    }

    func removeResetContextMarker() {
        resetMarker = nil

        save()
    }

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
            resetMarker = nil
        } else {
            resetMarker = conversations.count - 1
        }

        save()
    }

    @MainActor
    func stopStreaming() {
        if let lastConcersationContent = lastConcersationContent {
            if lastConcersationContent.isEmpty {
                removeConversation(at: conversations.count - 1)
            }
        }
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
            if conversations[index].role != "user" {
                removeConversations(from: index)
            }
            await send(text: lastConversation.content, isRegen: true)
        }
    }

    @MainActor
    func edit(from index: Int, conversation: Conversation) async {
        removeConversations(from: index)
        await send(text: conversation.content)
    }

    @MainActor
    func edit(conversation: Conversation, editedContent: String) async {
        if let index = conversations.firstIndex(of: conversation) {
            removeConversations(from: index)
            await send(text: editedContent)
        }
    }

    @MainActor
    func retry() async {
        await send(text: lastConversation.content, isRetry: true)
    }

    @MainActor
    private func send(text: String, isRegen: Bool = false, isRetry: Bool = false) async {
        if let resetMarker = resetMarker {
            if resetMarker == 1 {
                removeResetContextMarker()
            }
        }

        if isReplying() {
            return
        }
        resetErrorDesc()

        var streamText = ""

        if !isRegen && !isRetry {
            appendConversation(Conversation(role: "user", content: text))
        }

        let openAIconfig = configuration.provider.config
        let service: OpenAI = OpenAI(configuration: openAIconfig)

        let systemPrompt = Conversation(role: "system", content: configuration.systemPrompt)

        var messages: [Conversation]

        if let marker = resetMarker {
            messages = Array(conversations.suffix(from: marker + 1).suffix(configuration.contextLength))
        } else {
            messages = Array(conversations.suffix(configuration.contextLength - 1))
        }

        var allMessages: [Conversation]

        if configuration.model == .ngemini {
            allMessages = messages
        } else {
            allMessages = [systemPrompt] + messages
        }

        let query = ChatQuery(model: configuration.model.id,
                              messages: allMessages.map({ conversation in
                                  conversation.toChat()
                              }),
                              temperature: configuration.temperature,
                              maxTokens: 3800,
                              stream: true)

        let lastConversationData = appendConversation(Conversation(role: "assistant", content: "", isReplying: true))

        #if os(iOS)
            streamingTask = Task {
                let application = UIApplication.shared
                let taskId = application.beginBackgroundTask {
                    // Handle expiration of background task here
                }

                // Start your network request here
                for try await result in service.chatsStream(query: query) {
                    streamText += result.choices.first?.delta.content ?? ""
                    conversations[conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                    lastConversationData.sync(with: conversations[conversations.count - 1])
                }

                // End the background task once the network request is finished
                application.endBackgroundTask(taskId)

        } #else
            streamingTask = Task {
                for try await result in service.chatsStream(query: query) {
                    streamText += result.choices.first?.delta.content ?? ""
                    conversations[conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
                }
//                lastConversationData.sync(with: conversations[conversations.count - 1])
            }

        #endif

        do {
            try await streamingTask?.value

            lastConversationData.sync(with: conversations[conversations.count - 1])

        } catch {
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
        if conversations.isEmpty {
            removeResetContextMarker()
        }

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
//            withAnimation {
                conversations.removeSubrange(index...)
//            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func removeAllConversations() {
//        withAnimation {
            resetMarker = nil
            conversations.removeAll()
//        }

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
