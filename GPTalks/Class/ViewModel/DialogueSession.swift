//
//  DialogueSession.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/3.
//

import Foundation
import SwiftUI
import SwiftUIX
import AudioToolbox

class DialogueSession: ObservableObject, Identifiable, Equatable, Hashable, Codable {
    
    struct Configuration: Codable {
        var temperature: Double
        var systemPrompt: String
        var contextLength: Int
        var service: AIProvider
        var model: Model
        
        init() {
            service = AppConfiguration.shared.preferredChatService
            model = service.preferredModel
            contextLength = service.contextLength
            temperature = service.temperature
            systemPrompt = service.systemPrompt
        }
        
    }
    
    //MARK: - Codable
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        configuration = try container.decode(Configuration.self, forKey: .configuration)
        conversations = try container.decode([Conversation].self, forKey: .conversations)
        date = try container.decode(Date.self, forKey: .date)
        id = try container.decode(UUID.self, forKey: .id)

        isReplying = false
        isStreaming = false
        input = ""
        
        service = configuration.service.service(configuration: configuration)
        

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
    
    @Published var isReplying: Bool = false
    @Published var isSending: Bool = false
//    @Published var bubbleText: String = ""
    @Published var isStreaming: Bool = false
    @Published var input: String = ""
    @Published var inputData: Data?
    @Published var sendingData: Data?
    @Published var title: String = "New Chat"
    @Published var conversations: [Conversation] = [] {
        didSet {
            if let date = conversations.last?.date {
                self.date = date
            }
        }
    }
    @Published var date = Date()
    
    private var initFinished = false
    //MARK: - Properties
    
    @Published var configuration: Configuration = Configuration() {
        didSet {
            service.configuration = configuration
            save()
        }
    }
        
    var lastMessage: String {
        // Do loading spinner here in viewbuilder
        return conversations.last?.content ?? ""
    }
        
    lazy var service: ChatService = configuration.service.service(configuration: configuration)
    
    init() {
        
    }
    
    //MARK: - Message Actions
    
    @MainActor
    func send(scroll: ((UnitPoint) -> Void)? = nil) async {
        let text = input
        input = ""
        await send(text: text, scroll: scroll)
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
    func regenerate(from index: Int, scroll: ((UnitPoint) -> Void)? = nil) async {
        let lastMessage = conversations[index-1].content
        conversations = Array(conversations[0...index-2])
        await send(text: lastMessage, scroll: scroll)
    }
    
    @MainActor
    func edit(from index: Int, conversation: Conversation, scroll: ((UnitPoint) -> Void)? = nil) async {
        conversations = Array(conversations[..<index])
        await send(text: conversation.content, scroll: scroll)
    }
    
    private var lastConversationData: ConversationData?
    
    @MainActor
    private func send(text: String, isRetry: Bool = false, scroll: ((UnitPoint) -> Void)? = nil) async {
        
        var streamText = ""
//        var conversation = Conversation(
//            isReplying: true,
//            isLast: true,
//            input: text,
//            inputData: data,
//            reply: "",
//            errorDesc: nil)
//        
//        var summaryPrompt = ""
//        let isSummary = text.lowercased().contains("//summarize")
//        
//        if conversations.count > 0 {
//            conversations[conversations.endIndex-1].isLast = false
//        }
//        
//        if isRetry {
//            isReplying = true
//            lastConversationData = appendConversation(conversation)
//        } else {
//            withAnimation(.easeInOut(duration: 0.25)) {
//                isReplying = true
//                lastConversationData = appendConversation(conversation)
//                scroll?(.bottom)
//            }
//        }
        
        isReplying = true
        appendConversation(Conversation(role: "user", content: text))
        scroll?(.bottom)
        
        lastConversationData = appendConversation(Conversation(role: "assistant", content: "", isReplying: true))
        
        do {
            try await Task.sleep(for: .milliseconds(260))
            isSending = false
//            bubbleText = ""
//            sendingData = nil
#if os(iOS)
            withAnimation {
                scroll?(.top)
                scroll?(.bottom)
            }
#else
            scroll?(.top)
            scroll?(.bottom)
#endif
//            if isSummary {
//                let components = text.components(separatedBy: " ")
//                let url = components[1]
//                let responseData = try await getSummary(url: url)
//                summaryPrompt = "Summarize the following in a concise manner: " + responseData
//            }
            
//            let stream = isSummary
//                ? try await service.sendMessage(summaryPrompt, data: data)
//                : try await service.sendMessage(text, data: data)
            
            let adjustedContext = adjustContext(from: conversations, limit: configuration.contextLength, systemPrompt: configuration.systemPrompt)
            
            let stream = try await service.sendMessage(adjustedContext)
            
            isStreaming = true
            
//            lastConversationData = appendConversation(Conversation(role: "assistant", content: "", isReplying: true))

            for try await text in stream {
                streamText += text
                conversations[conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
#if os(iOS)
                withAnimation {
                    scroll?(.top)///for an issue of iOS 16
                    scroll?(.bottom)
                }
#else
                scroll?(.top)
                scroll?(.bottom)/// withAnimation may cause scrollview jitter in macOS
#endif
            }
            lastConversationData?.sync(with: conversations[conversations.count - 1])
            isStreaming = false
            
//            if conversations.count == 1 { createTitle() }
        } catch {
            print(error.localizedDescription)
#if os(iOS)
//            withAnimation {
//                conversation.errorDesc = error.localizedDescription
//                lastConversationData?.sync(with: conversation)
//                scroll?(.bottom)
//            }
#else
//            conversation.errorDesc = error.localizedDescription
//            lastConversationData?.sync(with: conversation)
            scroll?(.bottom)
#endif
        }
#if os(iOS)
//        withAnimation {
//            conversation.isReplying = false
//            updateLastConversation(conversation)
//            isReplying = false
//            scroll?(.bottom)
//            save()
//        }
#else
        conversations[conversations.count - 1].isReplying = false
        updateLastConversation(conversations[conversations.count - 1])
        isReplying = false
        scroll?(.bottom)
        save()
#endif

    }
    
    func createTitle() {
        Task { @MainActor in
            do {
                let newTitle = try await service.createTitle()
                let words = newTitle.split(separator: " ")
                let firstFiveWords = words.prefix(5).joined(separator: " ")
                self.rename(newTitle: String(firstFiveWords))

               } catch let error {
                print(error)
            }
        }
    }
    
    func adjustContext(
        from conversations: [Conversation],
        limit: Int,
        systemPrompt: String
    ) -> [Conversation] {
        
        var newConversations: [Conversation] = []

        if systemPrompt != "" {
            newConversations.append(Conversation(role: "system", content: systemPrompt))
        }

        if conversations.count > limit {
            // If the initial list size is greater than the limit, append the last 'limit' elements
            newConversations += Array(conversations.suffix(limit))
        } else {
            // If the initial list size is less than or equal to the limit, append all elements
            newConversations += conversations
        }

        return newConversations
    }
}


extension DialogueSession {
    
    convenience init?(rawData: DialogueData) {
        self.init()
        guard let id = rawData.id,
              let date = rawData.date,
              let title = rawData.title,
              let configurationData = rawData.configuration,
              let conversations = rawData.conversations as? Set<ConversationData> else {
            return nil
        }
        self.rawData = rawData
        self.id = id
        self.date = date
        self.title = title
        if let configuration = try? JSONDecoder().decode(Configuration.self, from: configurationData) {
            self.configuration = configuration
        }
        
        self.conversations = conversations.compactMap { data in
            if let id = data.id,
               let content = data.content,
               let role = data.role ,
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
        
        //        self.conversations = conversations.compactMap { data in
        //            if let id = data.id,
        //               let input = data.input,
        //               let date = data.date {
        //                let conversation = Conversation(
        //                    id: id,
        //                    input: input,
        //                    inputData: data.inputData,
        //                    reply: data.reply,
        //                    errorDesc: data.errorDesc,
        //                    date: date
        //                )
        //                return conversation
        //            } else {
        //                return nil
        //            }
        //        }
        //        self.conversations.sort {
        //            $0.date < $1.date
        //        }
        //
        //        self.conversations.forEach {
        //            self.service.appendNewMessage(
        //                input: $0.input,
        //                reply: $0.reply ?? "")
        //        }
        //        if !self.conversations.isEmpty {
        //            self.conversations[self.conversations.endIndex-1].isLast = true
        //        }
        
//        self.conversations = self.conversations.reversed()
        
        
        self.conversations.sort {
            $0.date < $1.date
        }
        
//        for conversation in self.conversations {
//           if conversation.role == "user" {
//               self.service.appendNewUserMessage(input: conversation.content)
//           } else if conversation.role == "assistant" {
//               self.service.appendNewAssistantMessage(input: conversation.content)
//           }
//        }
//        

        
//        self.conversations.forEach { convo in
//            if convo.role == "user" {
//                self.service.appendNewUserMessage(input: convo.content)
//            } else if convo.role == "assistant" {
//                self.service.appendNewAssistantMessage(input: convo.content)
//            }
//        }
//        
        initFinished = true
    }
    
    @discardableResult
    func appendConversation(_ conversation: Conversation) -> ConversationData {
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
    
    func updateLastConversation(_ conversation: Conversation) {
        conversations[conversations.count - 1] = conversation
        lastConversationData?.sync(with: conversation)
    }
    
//    func removeConversation(_ conversation: Conversation) {
//        guard let index = conversations.firstIndex(where: { $0.id == conversation.id }) else {
//            return
//        }
//        removeConversation(at: index)
//    }
    
//    func removeConversation(at index: Int) {
//        let isLast = conversations.endIndex-1 == index
//        let conversation = conversations.remove(at: index)
//        if isLast && !conversations.isEmpty {
//            conversations[conversations.endIndex-1].isLast = true
//        }
//        do {
//            if let conversationsSet = rawData?.conversations as? Set<ConversationData>,
//               let conversationData = conversationsSet.first(where: {
//                $0.id == conversation.id
//            }) {
//                PersistenceController.shared.container.viewContext.delete(conversationData)
//            }
//            try PersistenceController.shared.save()
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
    
    func removeConversation(at index: Int) {
//        let isLast = conversations.endIndex-1 == index
        let conversation = conversations.remove(at: index)
//        if isLast && !conversations.isEmpty {
//            conversations[conversations.endIndex-1].isLast = true
//        }
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
    
//    func removeAllConversations() {
//        conversations.removeAll()
//        do {
//            let viewContext = PersistenceController.shared.container.viewContext
//            if let conversations = rawData?.conversations as? Set<ConversationData> {
//                conversations.forEach(viewContext.delete)
//            }
//            try PersistenceController.shared.save()
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
    
    func save() {
        guard initFinished else {
            return
        }
        do {
            rawData?.date = date
            rawData?.title = title
            rawData?.configuration = try JSONEncoder().encode(configuration)
            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    

    func getSummary(url: String) async throws -> String {
        
        @StateObject var configuration = AppConfiguration.shared
        
        let baseURL = "https://easy-text-ml.p.rapidapi.com/web2text/link"
        let endpoint = baseURL + "?link=" + url
        
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(configuration.rapidApiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.addValue("easy-text-ml.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let result = String(data: data, encoding: .utf8) ?? ""

        return result
    }

    
}

extension ConversationData {
    
    func sync(with conversation: Conversation) {
        id = conversation.id
        role = conversation.role
        content = conversation.content
        date = conversation.date
//        input = conversation.input
//        inputData = conversation.inputData
//        reply = conversation.reply
//        errorDesc = conversation.errorDesc
        do {
            try PersistenceController.shared.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}
