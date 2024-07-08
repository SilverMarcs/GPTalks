//
//  ConversationGroup.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import Foundation
import SwiftData
import OpenAI

@Model
final class ConversationGroup: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ConversationGroup(conversation: activeConversation.copy() as! Conversation)
        return copy
    }
    
    var id: UUID = UUID()
    var date: Date = Date()
    var session: Session?
    
    var role: ChatQuery.ChatCompletionMessageParam.Role {
        get { return activeConversation.role }
        set { activeConversation.role = newValue }
    }
    
    @Relationship(deleteRule: .cascade, inverse: \Conversation.group)
    var conversationsUnsorted: [Conversation] = []
    
    var conversations: [Conversation] {
        get { return conversationsUnsorted.sorted(by: { $0.date < $1.date }) }
        set { conversationsUnsorted = newValue }
    }
    
    var activeConversationIndex: Int = 0
    
    var activeConversation: Conversation {
        if let conversation = conversations[safe: activeConversationIndex] {
            return conversation
        }
        return Conversation(role: .user, content: "", group: self)
    }
    
    init(conversation: Conversation) {
        self.conversations = [conversation]
        self.role = conversation.role
    }
    
    init(conversation: Conversation, session: Session) {
        self.conversations = [conversation]
        self.role = conversation.role
        self.session = session
        conversation.group = self
    }
    
    func addConversation(_ conversation: Conversation) {
        conversations.append(conversation)
        activeConversationIndex = conversations.count - 1
    }
    
    func deleteConversation(_ conversation: Conversation) {
        if conversations.count <= 1 {
            session?.deleteConversationGroup(self)
            return
        }
        
        conversations.removeAll(where: { $0 == conversation })
    }
    
    func setActive(for conversation: Conversation) {
        guard let index = conversations.firstIndex(where: { $0 == conversation }) else {
            return
        }
        activeConversationIndex = index
    }
    
    var canGoRight: Bool {
        return activeConversationIndex < conversations.count - 1
    }
    
    func setActiveToRight() {
        if activeConversationIndex < conversations.count - 1 {
            activeConversationIndex += 1
        }
    }
    
    var canGoLeft: Bool {
        return activeConversationIndex > 0
    }
    
    func setActiveToLeft() {
        if activeConversationIndex > 0 {
            activeConversationIndex -= 1
        }
    }
    
    func deleteSelf() {
        session?.deleteConversationGroup(self)
    }
    
    func resetContext() {
        session?.resetContext(at: self)
    }
}