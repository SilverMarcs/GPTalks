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
    var totalTokens: Int = 0
    
    var statusId: Int = 1 // normal status
    var status: ChatStatus {
        get { ChatStatus(rawValue: statusId)! }
        set { statusId = newValue.id }
    }
    
    @Relationship(deleteRule: .nullify)
    var contextResetPoint: MessageGroup?
    var adjustedContext: [Message] {
        guard let resetPoint = contextResetPoint,
              let resetIndex = currentThread.firstIndex(of: resetPoint),
              resetIndex + 1 < currentThread.count else {
            return currentThread.map { $0.activeMessage }
        }

        return currentThread[(resetIndex + 1)...].map { $0.activeMessage }
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
        currentThread.last?.isReplying ?? false
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
        
        // Check if we're editing a message before the context reset point
        if let resetPoint = contextResetPoint,
           let resetIndex = currentThread.firstIndex(of: resetPoint),
           let editIndex = currentThread.firstIndex(of: userGroup),
           editIndex <= resetIndex {
            contextResetPoint = nil
        }
        
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
       
       // Check if we're regenerating a message before the context reset point
       // TODO: convert unsetting reset point to a private func
       if let resetPoint = contextResetPoint,
          let resetIndex = currentThread.firstIndex(of: resetPoint),
          index <= resetIndex {
           contextResetPoint = nil
       }
       
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
        
        guard let last = currentThread.last else { return }
        last.isReplying = false
        if last.activeMessage.content.isEmpty {
            deleteLastMessage()
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        scrollBottom()
        AppConfig.shared.hasUserScrolled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Float.UIIpdateInterval) {
            if let lastMessage = self.currentThread.last, lastMessage.content.isEmpty, lastMessage.role == .assistant {
                self.deleteLastMessage()
            }
        }
    }
    
    func generateTitle(forced: Bool = false) async {
        guard status != .quick else { return }
        guard forced || currentThread.count <= 2 else { return }
        
        if let newTitle = await TitleGenerator.generateTitle(messages: currentThread.map( { $0.activeMessage } ), provider: config.provider) {
            self.title = newTitle
        }
    }

    func resetContext(at message: MessageGroup) {
        if contextResetPoint == message {
            contextResetPoint = nil
        } else {
            contextResetPoint = message
        }
    }

    
    func deleteLastMessage() {
        guard let lastGroup = currentThread.last, !lastGroup.isReplying else { return }
        
        if currentThread.count == 1 {
            // If this is the only message group, clear the root message
            rootMessage = nil
        } else {
            // Find the second to last group and set its next to nil
            let secondToLastGroup = currentThread[currentThread.count - 2]
            secondToLastGroup.activeMessage.next = nil
        }

        // Clear error message if we're deleting the last message
        errorMessage = ""
    }
    
    func deleteAllMessages() {
        rootMessage = nil
        stopStreaming()
        errorMessage = ""
        totalTokens = 0

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
