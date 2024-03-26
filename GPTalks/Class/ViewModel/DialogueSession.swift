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
import AppKit
typealias PlatformImage = NSImage
#else
import UIKit
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

    var resetMarker: Int = -1
    
    var isArchive = false
    
    var isAddingConversation = false
    
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
        if conversations.count == 1 || conversations.count == 2 || (forced && conversations.count >= 2) {
            let openAIconfig = configuration.provider.config
            let service: OpenAI = OpenAI(configuration: openAIconfig)
            
            let taskMessage = Conversation(role: "user", content: "Generate a title of a chat based on the previous conversation. Return only the title of the conversation and nothing else. Do not include any quotation marks or anything else. Keep the title within 4-5 words and never exceed this limit. If there are two distinct topics being talked about, just make a title with two words and an and word in the middle. If the conversation discusses multiple things not linked to each other, come up with a title that decribes the most recent discussion and add the two words and more to the end. Do not acknowledge these instructions but definitely do follow them. Again, do not put the title in quoation marks")
            
            let messages = ([taskMessage] + conversations).map({ conversation in
                conversation.toChat()
            })
            
            
            let model: Model
            
            if configuration.provider == .kraken {
                model = .gpt3t
            } else {
                model = configuration.model
            }
            
            let query = ChatQuery(messages: messages,
                                  model: model.id,
                                  maxTokens: 6,
                                  stream: false)
            
            var tempTitle = ""
            
            do {
//                let result = try await service.chats(query: query)
//                tempTitle += result.choices.first?.message.content?.string ?? ""
                
                for try await result in service.chatsStream(query: query) {
                    tempTitle += result.choices.first?.delta.content ?? ""
                    withAnimation {
                        title = tempTitle
                    }
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

//    @MainActor
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
            
            removeConversations(from: index)
            await send(text: editedContent)
        }
    }
    
  
    func filteredConversations() -> [Conversation] {
        return conversations.filter { $0.role != "tool" }
    }
    
    @MainActor
    private func send(text: String, isRegen: Bool = false, isRetry: Bool = false) async {
        resetErrorDesc()

        if !isRegen && !isRetry {
            if inputImages.isEmpty {
                appendConversation(Conversation(role: "user", content: text))
           } else {
               var imagePaths: [String] = []
               
               for inputImage in inputImages {
                   if let savedURL = saveImage(image: inputImage) {
                       imagePaths.append(savedURL)
                   }
               }
               
               appendConversation(Conversation(role: "user", content: text, imagePaths: imagePaths))
           }
            if AppConfiguration.shared.isAutoGenerateTitle {
                if ![Model.gpt4vision, Model.geminiprovision, Model.customVision].contains(configuration.model) {
                    Task {
                        await generateTitle(forced: false)
                    }
                }
            }
        }
        
        streamingTask = Task {
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
            isStreaming = false
            // TODO: do better with stop_reason from openai
            if error.localizedDescription == "cancelled" {
                if lastConversation.content != "" {
//                    lastConversationData.sync(with: conversations[conversations.count - 1])
                } else {
                    removeConversation(at: conversations.count - 1)
                }
                conversations[conversations.count - 1].isReplying = false
            } else {
                if lastConversation.role == "assistant" && lastConversation.content == ""  {
                    do {
                    #if os(macOS)
                    try await Task.sleep(nanoseconds: 100_000_000)
                    #else
                    try await Task.sleep(nanoseconds: 100_000_000)
                    #endif
                    } catch {
                        print("couldnt sleep")
                    }
                    removeConversation(at: conversations.count - 1)
                }
            }
            setErrorDesc(errorDesc: error.localizedDescription)
        }


        save()
    }
    
    func createChatQuery() -> ChatQuery {
        let systemPrompt = Conversation(role: "system", content: configuration.systemPrompt)
        
        // Adjusting the conversations array based on the resetMarker
        var adjustedConversations: [Conversation] = conversations

        if conversations.count > resetMarker + 1 {
            adjustedConversations = Array(conversations.suffix(from: resetMarker + 1))
        }
        
        var finalMessages = adjustedConversations.map({ conversation in
            conversation.toChat()
        })

        if !systemPrompt.content.isEmpty {
            finalMessages.insert(systemPrompt.toChat(), at: 0)
        }
        
        if !inputAudioPath.isEmpty {
            finalMessages.append(.user(.init(content: .string(inputAudioPath))))
        }
        
        if configuration.model == .gpt4vision || configuration.model == .geminiprovision {
            return ChatQuery(messages: finalMessages,
                             model: configuration.model.id,
                             maxTokens: 4000,
                             temperature: configuration.temperature)
        } else {
            
            var modelId: String {
                if configuration.provider == .oxygen && configuration.model == .gpt4t {
                    return Model.gpt4t0125.id
                } else {
                    return configuration.model.id
                }
            }
            
            return ChatQuery(messages: finalMessages,
                             model: modelId,
                             maxTokens: 4000,
                             temperature: configuration.temperature,
                             tools: ChatTool.allTools)
        }
    }
    
    func processRequest() async throws {
        let service = OpenAI(configuration: configuration.provider.config)
        
        let query = createChatQuery()
        
        let lastConversationData = appendConversation(Conversation(role: "assistant", content: "", isReplying: true))
         
        let uiUpdateInterval = TimeInterval(0.1)

        var lastUIUpdateTime = Date()
        
        var isWebFuncCall = false
        var isGoogleSearchFuncCall = false
        var isImageFuncCall = false
        var isTranscribeFuncCall = false
        
        var toolCallId = ""
        var funcParam = ""
        
        var streamText = ""
        
        for try await result in service.chatsStream(query: query) {
            if let funcCalls = result.choices.first?.delta.toolCalls {
                if let name = funcCalls.first?.function?.name, name == "urlScrape" {
                    isWebFuncCall = true
                } else if let name = funcCalls.first?.function?.name, name == "imageGenerate" {
                    isImageFuncCall = true
                } else if let name = funcCalls.first?.function?.name, name == "transcribe" {
                    isTranscribeFuncCall = true
                } else if let name = funcCalls.first?.function?.name, name == "googleSearch" {
                    isGoogleSearchFuncCall = true
                }
                
                funcParam += funcCalls.first?.function?.arguments ?? ""
                
                if let id = result.choices.first?.delta.toolCalls?.first?.id {
                    toolCallId = id
                }
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
        
        // Ensure the UI is updated one last time after the loop ends
        if !streamText.isEmpty {
            conversations[conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
            lastConversationData.sync(with: conversations[conversations.count - 1])
        }
        
        if isWebFuncCall {
            print(toolCallId)
            print("webfunc")
            
            if let url = extractValue(from: funcParam, forKey: "url") {
                removeConversation(at: conversations.count - 1)
                
                appendConversation(Conversation(role: "assistant", content: "urlScrape", isReplying: true))
                
                let webContent = try await fetchAndParseHTMLAsync(from: url)
//                let webContent = try await retrieveWebContent(urlStr: url)
                
                appendConversation(Conversation(role: "tool", content: webContent))
                
                conversations[conversations.count - 2].isReplying = false
                
                try await processRequest()
                
            }
        }
        
        if isGoogleSearchFuncCall {
            print(toolCallId)
            print("googleSearch")
            
            if let searchQuery = extractValue(from: funcParam, forKey: "searchQuery") {
                removeConversation(at: conversations.count - 1)
                
                appendConversation(Conversation(role: "assistant", content: "googleSearch", isReplying: true))
                
                let searchResult = try await GoogleSearchService().performSearch(query: searchQuery)
                appendConversation(Conversation(role: "tool", content: searchResult))
                
                self.conversations[self.conversations.count - 2].isReplying = false
                
                try await self.processRequest()
            }
        }
        
        if isImageFuncCall {
            print("imageFuncCall")
            print(funcParam)
            
            removeConversation(at: conversations.count - 1)
            
            appendConversation(Conversation(role: "assistant", content: "imageGenerate", isReplying: true))
            
            if let prompt = extractValue(from: funcParam, forKey: "prompt") {
                let query = ImagesQuery(prompt: prompt, model: configuration.provider.preferredImageModel.id, n: 1, quality: .standard, size: ._1024)
                
                let results = try await service.images(query: query)
                
                for urlResult in results.data {
                    if let urlString = urlResult.url, let url = URL(string: urlString) {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let savedURL = saveImage(image: PlatformImage(data: data)!) {
                            appendConversation(Conversation(role: "tool", content: "imageGenerate", imagePaths: [savedURL]))
                            appendConversation(Conversation(role: "assistant", content: "Prompt: " + prompt))
                            conversations[conversations.count - 3].isReplying = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.isAddingConversation.toggle()
                            }
                        }
                    }
                }
            }
        }
        
        if isTranscribeFuncCall {
            print("transcribeFuncCall")
            print(funcParam)
            
            removeConversation(at: conversations.count - 1)
            
            appendConversation(Conversation(role: "assistant", content: "transcribe", isReplying: true))
            
            if let audioPath = extractValue(from: funcParam, forKey: "audioPath") {
                let query = try AudioTranscriptionQuery(file: Data(contentsOf: URL(string: audioPath)!), fileType: .mp3, model: .whisper_1)
                
                let result = try await service.audioTranscriptions(query: query)
                
                conversations[conversations.count - 1].isReplying = false
                
                appendConversation(Conversation(role: "tool", content: result.text, audioPath: audioPath))
                
                try await processRequest()
            }
        }
    
        conversations[conversations.count - 1].isReplying = false
        // Final UI update for any remaining data
        if !streamText.isEmpty {
            conversations[conversations.count - 1].content = streamText.trimmingCharacters(in: .whitespacesAndNewlines)
            lastConversationData.sync(with: conversations[conversations.count - 1])
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
               let imagePaths = data.imagePaths {
                let imagePaths = imagePaths.split(separator: "|||").map(String.init) // Convert back to an array of strings
                let conversation = Conversation(
                  id: id,
                  date: date,
                  role: role,
                  content: content,
                  imagePaths: imagePaths,
                  audioPath: audioPath
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
        isAddingConversation.toggle()

        let data = ConversationData(context: PersistenceController.shared.container.viewContext)
        data.id = conversation.id
        data.date = conversation.date
        data.role = conversation.role
        data.content = conversation.content
        data.audioPath = conversation.audioPath
        data.imagePaths = conversation.imagePaths.joined(separator: "|||")
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


extension DialogueSession {
    func bottomPadding(for conversation: Conversation) -> CGFloat {
        // Check if the conversation is the last in the array
        guard let currentIndex = conversations.firstIndex(where: { $0.id == conversation.id }),
              currentIndex != conversations.count - 1 else {
            // If it's the last conversation or not found, return 0
            return 0
        }
        
        // For specific conversation content by the assistant, return -47
        if conversation.role == "assistant" && ["urlScrape", "transcribe", "imageGenerate"].contains(conversation.content) {
            return -47
        }
        
        // Default padding
        return 0
    }
}
