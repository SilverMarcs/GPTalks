//
//  ThreadGroup.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import Foundation
import SwiftData
import OpenAI
import SwiftUI

@Model
final class ThreadGroup {
    var id: UUID = UUID()
    var date: Date = Date()
    var session: Chat?
    
    var activeThreadIndex: Int = 0
    
    @Relationship(deleteRule: .cascade, inverse: \Thread.group)
    var conversationsUnsorted: [Thread] = []
    
    var role: ThreadRole {
        get { return activeThread.role }
        set { activeThread.role = newValue }
    }
    
    var conversations: [Thread] {
        get { return conversationsUnsorted.sorted(by: { $0.date < $1.date }) }
        set { conversationsUnsorted = newValue }
    }
    
    #warning("find better way to do this")
    var activeThread: Thread {
        if let conversation = conversations[safe: activeThreadIndex] {
            return conversation
        }
        
        return dummyThread
    }
    
    var tokenCount: Int {
        return activeThread.tokenCount
    }
    
    init(role: ThreadRole) {
        self.role = role
    }
    
    init(conversation: Thread) {
        self.conversations = [conversation]
        self.role = conversation.role
    }
    
    init(conversation: Thread, session: Chat) {
        self.conversations = [conversation]
        self.role = conversation.role
        self.session = session
        conversation.group = self
    }
    
    func addThread(_ conversation: Thread) {
        conversations.append(conversation)
        activeThreadIndex = conversations.count - 1
    }
    
    func deleteThread(_ conversation: Thread) {
        conversations.removeAll(where: { $0 == conversation })
        
        if conversations.count < 1 {
            session?.deleteThreadGroup(self)
            return
        }
    }
    
    var canGoRight: Bool {
        return activeThreadIndex < conversations.count - 1
    }
    
    func setActiveToRight() {
        if activeThreadIndex < conversations.count - 1 {
            activeThreadIndex += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.session?.proxy?.scrollTo(self, anchor: .bottom)
        }
    }
    
    var canGoLeft: Bool {
        return activeThreadIndex > 0
    }
    
    func setActiveToLeft() {
        if activeThreadIndex > 0 {
            activeThreadIndex -= 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.session?.proxy?.scrollTo(self, anchor: .bottom)
        }
    }
    
    func deleteSelf() {
        session?.deleteThreadGroup(self)
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
    
    func copy() -> ThreadGroup{
        return ThreadGroup(conversation: activeThread.copy())
    }
}

let dummyThread = Thread(role: .user, content: "")
