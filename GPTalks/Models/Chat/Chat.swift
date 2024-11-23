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
    func sendInput() async {
        errorMessage = ""
        
        guard !inputManager.prompt.isEmpty else { return }

        if inputManager.state == .editing {
            await handleEditing()
        } else {
            await handleNewInput()
        }
    }

    @MainActor
    private func handleEditing() async {
        guard let index = inputManager.editingIndex else { return }
        messages.removeSubrange((index + 1)...)
        unsetResetMarker(at: index)
        let editingMessage = messages[index]
        editingMessage.content = inputManager.prompt
        editingMessage.dataFiles = inputManager.dataFiles
        inputManager.reset()
        await regenerate(message: editingMessage)
    }

    @MainActor
    private func handleNewInput() async {
        let user = Message(role: .user, content: inputManager.prompt, dataFiles: inputManager.dataFiles)
        addMessage(user)
        inputManager.reset()
        let assistant: Message = .init(role: .assistant)
        addMessage(assistant)
        await processRequest(message: assistant)
    }
    
    @MainActor
    func regenerate(message: MessageGroup) async {
        guard let index = messages.firstIndex(where: { $0 == message }) else { return }
        unsetResetMarker(at: index)
        
        if message.role == .assistant {
            messages.removeSubrange((index + 1)...)
            let nextAssistant: Message = .init(role: .assistant)
            message.addMessage(nextAssistant)
            
            await processRequest(message: nextAssistant)
        } else if message.role == .user {
            let nextAssistant: Message = .init(role: .assistant)
            let nextIndex = index + 1
            if nextIndex < messages.count, messages[nextIndex].role == .assistant {
                messages[nextIndex].addMessage(nextAssistant)
            } else {
                addMessage(nextAssistant)
            }
            messages.removeSubrange((index + 2)...)
            await processRequest(message: nextAssistant)
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
        guard forced || adjustedMessages.count <= 2 else { return }
        
        if let newTitle = await TitleGenerator.generateTitle(messages: adjustedMessages.map( { $0.activeMessage } ), provider: config.provider) {
            self.title = newTitle
        }
    }

    func addMessage(_ message: Message) {
        message.provider = config.provider
        message.model = config.model
        
        if message.role == .assistant {
            message.isReplying = true
        }
        
        let group = MessageGroup(message: message)
        messages.append(group)
        scrollBottom()
    }
    
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
    
    func copy(from message: MessageGroup? = nil, purpose: ChatConfigPurpose) async -> Chat {
        let newChat = Chat(config: config.copy(purpose: purpose))
        
        let leading = switch purpose {
            case .chat: "Ψ"
            case .quick: "↯"
            case .title: "T"
        }
        
        newChat.title = "\(leading) \(self.title)"
        newChat.totalTokens = self.totalTokens
        
        if let message = message, let index = messages.firstIndex(of: message) {
            newChat.messages = messages.prefix(through: index).map { $0.copy() }
        } else {
            newChat.messages = messages.map { $0.copy() }
        }
        
        return newChat
    }
}
