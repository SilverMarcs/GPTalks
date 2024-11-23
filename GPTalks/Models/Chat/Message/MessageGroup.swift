//
//  MessageGroup.swift
//  GPTalks
//
//  Created by Zabir Raihan on 22/11/2024.
//

import Foundation
import SwiftData

@Model
final class MessageGroup {
    var id: UUID = UUID()
    var date: Date = Date()
    
    var chat: Chat?
    
    var provider: Provider? {
        activeMessage.provider
    }
    
    var model: AIModel? {
        activeMessage.model
    }
    
    var content: String {
        get {
            activeMessage.content
        }
        set {
            activeMessage.content = newValue
        }
    }

    var dataFiles: [TypedData] {
        get {
            activeMessage.dataFiles
        }
        set {
            activeMessage.dataFiles = newValue
        }
    }
    
    var role: MessageRole {
        get {
            activeMessage.role
        }
        set {
            activeMessage.role = newValue
        }
    }
    
    var isReplying: Bool {
        get {
            activeMessage.isReplying
        }
        set {
            activeMessage.isReplying = newValue
        }
    }
    
    var toolCalls: [ChatToolCall] {
        get {
            activeMessage.toolCalls
        }
        set {
            activeMessage.toolCalls = newValue
        }
    }
    
    var toolResponse: ToolResponse? {
        get {
            activeMessage.toolResponse
        }
        set {
            activeMessage.toolResponse = newValue
        }
    }
    
    @Relationship(deleteRule: .nullify)
    var activeMessage: Message
    
    @Relationship(deleteRule: .cascade)
    var allUnorderedMessages: [Message] = []
    var allMessages: [Message] {
        get {
            allUnorderedMessages.sorted(by: { $0.date < $1.date })
        }
        set {
            allUnorderedMessages = newValue
        }
    }
    
    init(message: Message) {
        self.allUnorderedMessages = [message]
        self.activeMessage = message
    }
    
    func addMessage(_ message: Message) {
        message.provider = chat?.config.provider
        message.model = chat?.config.model
        
        if message.role == .assistant {
            message.isReplying = true
        }
        allMessages.append(message)
        activeMessage = message
    }
    
    var currentMessageIndex: Int {
        allMessages.firstIndex(of: activeMessage) ?? 0
    }
    
    var canGoToPrevious: Bool {
        currentMessageIndex > 0
    }
    
    var canGoToNext: Bool {
        currentMessageIndex < allMessages.count - 1
    }
    
    func goToPreviousMessage() {
        guard canGoToPrevious else { return }
        activeMessage = allMessages[currentMessageIndex - 1]
    }
    
    func goToNextMessage() {
        guard canGoToNext else { return }
        activeMessage = allMessages[currentMessageIndex + 1]
    }
    
    func copy() -> MessageGroup {
        return MessageGroup(message: activeMessage.copy())
    }
}
