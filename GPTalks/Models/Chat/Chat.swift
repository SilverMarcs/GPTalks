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
    
    @Relationship(deleteRule: .cascade, inverse: \Message.chat)
    var unorderedMessages =  [Message]()
    var messages: [Message] {
        get { return unorderedMessages.sorted(by: {$0.date < $1.date})}
        set { unorderedMessages = newValue }
    }
    var adjustedMessages: [Message] {
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
    func processRequest() async {
        errorMessage = ""
        date = Date()
        streamingTask = Task {
            let streamer = StreamHandler(chat: self)
            
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
        await processRequest()
    }
    
    @MainActor
    func regenerate(message: Message) async {
        guard let index = messages.firstIndex(where: { $0 == message }) else { return }
        unsetResetMarker(at: index)
        messages.removeSubrange(message.role == .assistant ? index... : (index + 1)...)
        await processRequest()
    }
    
    func stopStreaming() {
        AppConfig.shared.hasUserScrolled = false
        streamingTask?.cancel()
        streamingTask = nil
        
        guard let last = messages.last else { return }
        last.isReplying = false
        if last.content.isEmpty {
            deleteMessage(last)
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
        
        if let newTitle = await TitleGenerator.generateTitle(messages: adjustedMessages, provider: config.provider) {
            self.title = newTitle
        }
    }

    func addMessage(_ message: Message) {
        if message.role == .assistant {
            message.isReplying = true
        }
        messages.append(message)
        scrollBottom()
    }
    
    private func unsetResetMarker(at index: Int) {
        if let resetMarker = resetMarker, index <= resetMarker {
            self.resetMarker = nil
        }
    }

    func resetContext(at message: Message) {
        guard let index = messages.firstIndex(of: message) else { return }
        resetMarker = (resetMarker == index) ? nil : index
        if resetMarker == messages.count - 1 {
            scrollBottom()
        }
    }
    
    func deleteMessage(_ message: Message) {
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
        
        if let message = message, let index = messages.firstIndex(of: message) {
            newChat.messages = messages.prefix(through: index).map { $0.copy() }
        } else {
            newChat.messages = messages.map { $0.copy() }
        }
        
        return newChat
    }
}
