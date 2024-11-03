//
//  ConversationGroup.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import Foundation
import SwiftData
import OpenAI
import SwiftUI

@Model
final class ConversationGroup {
    var id: UUID = UUID()
    var date: Date = Date()
    var session: ChatSession?
    
    var activeConversationIndex: Int = 0
    
    @Relationship(deleteRule: .cascade, inverse: \Conversation.group)
    var conversationsUnsorted: [Conversation] = []
    
    var role: ConversationRole {
        get { return activeConversation.role }
        set { activeConversation.role = newValue }
    }
    
    var conversations: [Conversation] {
        get { return conversationsUnsorted.sorted(by: { $0.date < $1.date }) }
        set { conversationsUnsorted = newValue }
    }
    
    #warning("find better way to do this")
    var activeConversation: Conversation {
        if let conversation = conversations[safe: activeConversationIndex] {
            return conversation
        }
        
        return dummyConversation
    }
    
    var tokenCount: Int {
        return activeConversation.tokenCount
    }
    
    init(role: ConversationRole) {
        self.role = role
    }
    
    init(conversation: Conversation) {
        self.conversations = [conversation]
        self.role = conversation.role
    }
    
    init(conversation: Conversation, session: ChatSession) {
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
        conversations.removeAll(where: { $0 == conversation })
        
        if conversations.count < 1 {
            session?.deleteConversationGroup(self)
            return
        }
    }
    
    var canGoRight: Bool {
        return activeConversationIndex < conversations.count - 1
    }
    
    func setActiveToRight() {
        if activeConversationIndex < conversations.count - 1 {
            activeConversationIndex += 1
        }
        session?.proxy?.scrollTo(self, anchor: .bottom)
    }
    
    var canGoLeft: Bool {
        return activeConversationIndex > 0
    }
    
    func setActiveToLeft() {
        if activeConversationIndex > 0 {
            activeConversationIndex -= 1
        }
        session?.proxy?.scrollTo(self, anchor: .bottom)
    }
    
    func deleteSelf() {
        session?.deleteConversationGroup(self)
    }

    func setupEditing() {
        session?.inputManager.setupEditing(for: self)
        withAnimation {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    self.session?.proxy?.scrollTo(self, anchor: .top)
                }
            }
        }
    }
    
    func copy() -> ConversationGroup{
        return ConversationGroup(conversation: activeConversation.copy())
    }
}

let dummyConversation = Conversation(role: .user, content: "")
