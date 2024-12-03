//
//  MessageGroup.swift
//  GPTalks
//
//  Created by Zabir Raihan on 22/11/2024.
//

import SwiftData
import SwiftUI

@Model
final class MessageGroup: Hashable, Identifiable {
    var id: UUID = UUID()
    var date: Date = Date()
    
    var chat: Chat?
    
    @Relationship(deleteRule: .cascade)
    var rootMessage: Message?
    
    @Relationship(deleteRule: .cascade)
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
    
    func copy() -> MessageGroup {
        return MessageGroup(message: activeMessage.copy())
    }
    
    // MARK: - computed message properties
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
    
    var useCache: Bool {
        get {
            activeMessage.useCache
        }
        set {
            activeMessage.useCache = newValue
        }
    }
    
    // MARK: - Active Message Navigation
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
        
        scrollToActiveMessage()
    }
    
    func goToNextMessage() {
        guard canGoToNext else { return }
        activeMessage = allMessages[currentMessageIndex + 1]
        
        scrollToActiveMessage()
    }
    
    private func scrollToActiveMessage() {
        let anchor: UnitPoint = role == .assistant ? .bottom : .top
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Scroller.scroll(to: anchor, of: self)
        }
    }
    
    func deleteActiveMessage() {
        guard allMessages.count > 1, let index = allMessages.firstIndex(of: activeMessage) else { return }
        
        allUnorderedMessages.removeAll { $0 == activeMessage }
        
        let nextIndex = min(index, allMessages.count - 1)
        activeMessage = allMessages[nextIndex]
    }
    
    // MARK: - Secondary Message Navigation
    @Attribute(.ephemeral)
    var isSplitView: Bool = false
    @Attribute(.ephemeral)
    var secondaryMessageIndex: Int = 0
    
    var secondaryMessages: [Message] {
        allMessages.filter { $0 != activeMessage }
    }
    
    func toggleSplitView() {
        isSplitView.toggle()
        if isSplitView {
            secondaryMessageIndex = 0
        }
        Scroller.scroll(to: .top, of: self)
    }
    
    func nextSecondaryMessage() {
        guard secondaryMessageIndex < secondaryMessages.count - 1 else { return }
        secondaryMessageIndex += 1
    }
    
    func previousSecondaryMessage() {
        guard secondaryMessageIndex > 0 else { return }
        secondaryMessageIndex -= 1
    }
    
    var canGoToNextSecondary: Bool {
        secondaryMessageIndex < secondaryMessages.count - 1
    }
    
    var canGoToPreviousSecondary: Bool {
        secondaryMessageIndex > 0
    }
}
