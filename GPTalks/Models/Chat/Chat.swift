//
//  Chat.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftData
import SwiftUI

@Model
final class Chat {
    var id: UUID = UUID()
    var date: Date = Date()
    var title: String = "New Chat Session"
    var errorMessage: String = ""
    var resetMarker: Int?
    var totalTokens: Int = 0
    
    var statusId: Int = 1 // normal status
    var status: ChatStatus {
        get { ChatStatus(rawValue: statusId)! }
        set { statusId = newValue.id }
    }
    
    @Relationship(deleteRule: .cascade, inverse: \MessageGroup.chat)
    var unorderedMessages =  [MessageGroup]()
    var messages: [MessageGroup] {
        get { return unorderedMessages.sorted(by: {$0.date < $1.date})}
        set { unorderedMessages = newValue }
    }
    
    var adjustedMessages: [MessageGroup] {
        guard let resetMarker = resetMarker else { return messages }
        return Array(messages.dropFirst(resetMarker))
    }

    @Relationship(deleteRule: .cascade)
    var rootMessage: MessageGroup?
    
    var currentThread: [MessageGroup] {
        var thread: [MessageGroup] = []
        var currentGroup = rootMessage
        
        while let group = currentGroup {
            thread.append(group)
            currentGroup = group.activeMessage.next
        }
        
        return thread
    }
    
    @Relationship(deleteRule: .cascade)
    var config: ChatConfig
    
    @Transient
    var streamingTask: Task<Void, Error>?
    @Transient
    var isReplying: Bool {
        messages.last?.isReplying ?? false
    }

    @Transient
    var inputManager = InputManager()
    
    init(config: ChatConfig) {
        self.config = config
    }
    
    @MainActor
    func processRequest(message: Message) async {
        errorMessage = ""
        date = Date()
        streamingTask = Task {
            let streamer = StreamHandler(chat: self, assistant: message)
            
            // Request background task before starting network operations
            #if !os(macOS)
            let backgroundTaskId = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?.streamingTask?.cancel()
            }
            
            defer {
                // Ensure we end the background task when done
                UIApplication.shared.endBackgroundTask(backgroundTaskId)
            }
            #endif
            
            do {
                try await streamer.handleRequest()
            } catch {
                handleError(error)
            }
            
            streamingTask?.cancel()
            streamingTask = nil
        }
        
        if AppConfig.shared.autogenTitle {
            Task { await generateTitle() }
        }
    }


     @MainActor
     func editMessage(_ message: Message) async {
        guard let userGroup = currentThread.first(where: { $0.activeMessage == message }) else { return }
        
        let newUserMessage = Message(role: .user, content: inputManager.prompt, provider: message.provider, model: message.model, dataFiles: inputManager.dataFiles)
        userGroup.addMessage(newUserMessage)
        
        // Create a new assistant message group
        let newAssistantMessage = Message(role: .assistant, provider: config.provider, model: config.model, isReplying: true)
        let newAssistantGroup = MessageGroup(message: newAssistantMessage)
        newAssistantGroup.chat = self
        
        // Set the new assistant group as the next of the new user message
        newUserMessage.next = newAssistantGroup
         
        // Process the new assistant message
        await processRequest(message: newAssistantMessage)
    }

    @MainActor
    func sendInput() async {
        errorMessage = ""
        
        guard !inputManager.prompt.isEmpty else { return }
        
        if let editingMessage = inputManager.editingMessage {
            await editMessage(editingMessage)
            inputManager.editingMessage = nil
        } else {
            let userMessage = Message(role: .user, content: inputManager.prompt, dataFiles: inputManager.dataFiles)
            let userGroup = MessageGroup(message: userMessage)
            userGroup.chat = self
            
            if rootMessage == nil {
                rootMessage = userGroup
            } else {
                let lastGroup = currentThread.last!
                lastGroup.activeMessage.next = userGroup
            }
            
            let assistantMessage = Message(role: .assistant, provider: config.provider, model: config.model, isReplying: true)
            let assistantGroup = MessageGroup(message: assistantMessage)
            assistantGroup.chat = self
            userGroup.activeMessage.next = assistantGroup
             
            await processRequest(message: assistantMessage)
        }
         
        inputManager.reset()
    }

   @MainActor
   func regenerate(message: MessageGroup) async {
       guard let index = currentThread.firstIndex(where: { $0 == message }) else { return }
       
       if message.role == .assistant {
           let newAssistantMessage = Message(role: .assistant)
           message.addMessage(newAssistantMessage)
           message.activeMessage.next = nil
           
           await processRequest(message: newAssistantMessage)
       } else if message.role == .user {
           if index + 1 < currentThread.count {
               let assistantGroup = currentThread[index + 1]
               let newAssistantMessage = Message(role: .assistant)
               assistantGroup.addMessage(newAssistantMessage)
               assistantGroup.activeMessage.next = nil
               
               await processRequest(message: newAssistantMessage)
           }
       }
   }
    
    func stopStreaming() {
        AppConfig.shared.hasUserScrolled = false
        streamingTask?.cancel()
        streamingTask = nil
        
        guard let last = messages.last else { return }
        last.isReplying = false
        if last.content.isEmpty {
            guard let currentIndex = last.allMessages.firstIndex(of: last.activeMessage),
                  currentIndex > 0 else {
                return
            }
            last.activeMessage = last.allMessages[currentIndex - 1]
            last.allMessages.remove(at: currentIndex)
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        scrollBottom()
        AppConfig.shared.hasUserScrolled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Float.UIIpdateInterval) {
            if let lastMessage = self.messages.last, lastMessage.content.isEmpty, lastMessage.role == .assistant {
                self.deleteMessage(lastMessage)
            }
        }
    }
    
    func generateTitle(forced: Bool = false) async {
        guard status != .quick else { return }
        guard forced || messages.count <= 2 else { return }
        
        if let newTitle = await TitleGenerator.generateTitle(messages: messages.map( { $0.activeMessage } ), provider: config.provider) {
            self.title = newTitle
        }
    }

//    func addMessage(_ message: Message, defensive: Bool = false) {
//        message.provider = config.provider
//        message.model = config.model
//        
//        if message.role == .assistant {
//            message.isReplying = true
//        }
//        
//        let group = MessageGroup(message: message)
//        if !defensive {
//            AppConfig.shared.hasUserScrolled = false
//        }
//        messages.append(group)
//        scrollBottom()
//    }
    
    private func unsetResetMarker(at index: Int) {
        if let resetMarker = resetMarker, index <= resetMarker {
            self.resetMarker = nil
        }
    }

    func resetContext(at message: MessageGroup) {
        guard let index = messages.firstIndex(of: message) else { return }
        resetMarker = (resetMarker == index) ? nil : index
        if resetMarker == messages.count - 1 {
            AppConfig.shared.hasUserScrolled = false
            scrollBottom()
        }
    }
    
    func deleteMessage(_ message: MessageGroup) {
        guard let index = messages.firstIndex(of: message) else { return }
        unsetResetMarker(at: index)
        messages.remove(at: index)
        if messages.count == 0 {
            errorMessage = ""
        }
    }

    func deleteAllMessages() {
        errorMessage = ""
        resetMarker = nil
        messages.removeAll()
    }
    
    func scrollBottom() {
        if let proxy = AppConfig.shared.proxy, !AppConfig.shared.hasUserScrolled {
            DispatchQueue.main.async {
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    func copy(from message: Message? = nil, purpose: ChatConfigPurpose) async -> Chat {
        let newChat = Chat(config: config.copy(purpose: purpose))
        
        let leading = switch purpose {
            case .chat: "Ψ"
            case .quick: "↯"
            case .title: "T"
        }
        
        newChat.title = "\(leading) \(self.title)"
        newChat.totalTokens = self.totalTokens
        
        var threadToCopy: [MessageGroup] = []
        
        if let message = message {
            // Find the MessageGroup containing the specified message
            if let groupIndex = currentThread.firstIndex(where: { $0.allMessages.contains(message) }) {
                threadToCopy = Array(currentThread.prefix(through: groupIndex))
            }
        } else {
            threadToCopy = currentThread
        }
        
        // Copy the thread
        var previousGroup: MessageGroup?
        for group in threadToCopy {
            let copiedGroup = group.copy()
            copiedGroup.chat = newChat
            
            if let previousGroup = previousGroup {
                previousGroup.activeMessage.next = copiedGroup
            } else {
                newChat.rootMessage = copiedGroup
            }
            
            previousGroup = copiedGroup
        }
        
        return newChat
    }
}
