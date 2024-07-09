//
//  Item.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import Foundation
import SwiftData
import SwiftUI
import OpenAI

@Model
final class Session {
    var id: UUID = UUID()
    var date: Date = Date()
    var title: String = "New Session"
    var isStarred: Bool = false
    var errorMessage: String = ""
    var resetMarker: Int?

    @Relationship(deleteRule: .cascade, inverse: \ConversationGroup.session)
    var unorderedGroups =  [ConversationGroup]()
    
    @Transient
    var groups: [ConversationGroup] {
        get {return unorderedGroups.sorted(by: {$0.date < $1.date})}
        set { unorderedGroups = newValue }
    }
    
    var adjustedGroups: [ConversationGroup] {
        // return all groups after the reset marker
        if let resetMarker = resetMarker {
            return Array(groups.suffix(from: resetMarker + 1))
        } else {
            return groups
        }
    }
    
    var tokenCounter: Int {
        let messageTokens = adjustedGroups.reduce(0) { $0 + $1.activeConversation.countTokens() }
        let sysPromptTokens = tokenCount(text: config.systemPrompt)
        
        return messageTokens + sysPromptTokens
    }
    
    @Transient
    var streamingTask: Task<Void, Error>?
    
    @Attribute(.ephemeral) 
    var isReplying: Bool {
        groups.last?.activeConversation.isReplying ?? false
    }
    
    @Transient
    var inputManager = InputManager()
    
    var config: SessionConfig
    
    @Transient
    let uiUpdateInterval = TimeInterval(0.1)
    
    init(config: SessionConfig = SessionConfig()) {
        self.config = config
    }
    
    @MainActor
    func sendInput(isRegen: Bool = false, regenContent: String? = nil) async {
        errorMessage = ""
        
        if !isRegen && inputManager.prompt.isEmpty {
            return
        }
        
        self.date = Date()
        
        if !isRegen {
            let content = inputManager.prompt
            inputManager.reset()
            let user = Conversation(role: .user, content: content, model: config.model)
            addConversationGroup(conversation: user)
        }
        
        streamingTask = Task(priority: .userInitiated) {
            try await processRequest(isRegen: isRegen, regenContent: regenContent)
        }
        
        do {
            try await streamingTask?.value
        } catch {
            print("Error: \(error)")
            errorMessage = error.localizedDescription
            
            if let lastGroup = groups.last, lastGroup.activeConversation.content.isEmpty {
                groups.removeLast()
            }
        }
    }

    @MainActor
    func processRequest(isRegen: Bool, regenContent: String?) async throws {
        var streamText = ""
        let uiUpdateInterval = TimeInterval(0.1)
        var lastUIUpdateTime = Date()
        
        var updatedConversationGroups = adjustedGroups.map { $0.copy() as! ConversationGroup }
        
        if isRegen, let regenContent = regenContent {
            // Add the regen content to the last user group
            if let lastUserGroupIndex = updatedConversationGroups.lastIndex(where: { $0.role == .user }) {
                let regenUserConversation = Conversation(role: .user, content: regenContent, model: config.model)
                updatedConversationGroups[lastUserGroupIndex] = ConversationGroup(conversation: regenUserConversation)
            }
        }
        
        let streamManager = StreamManager(config: config)
        let stream = streamManager.streamResponse(from: updatedConversationGroups)
        
        let assistant: Conversation
        if isRegen, let lastAssistantGroup = groups.last(where: { $0.role == .assistant }) {
            assistant = lastAssistantGroup.conversations.last ?? Conversation(role: .assistant, content: "", model: config.model)
        } else {
            assistant = Conversation(role: .assistant, content: "", model: config.model)
            addConversationGroup(conversation: assistant)
        }
        
        assistant.isReplying = true
        
        for try await content in stream {
            streamText += content
            let currentTime = Date()
            if currentTime.timeIntervalSince(lastUIUpdateTime) >= uiUpdateInterval {
                assistant.content = streamText
                lastUIUpdateTime = currentTime
            }
        }
        
        if !streamText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + uiUpdateInterval) {
                assistant.content = streamText
                assistant.isReplying = false
            }
        }
    }

    
    @MainActor
    func regenerate(assistantGroup: ConversationGroup) {
        guard assistantGroup.role == .assistant,
              let index = groups.firstIndex(where: { $0.id == assistantGroup.id }),
              index > 0 else {
            return
        }
        
        // Remove all groups after the given assistant group
        groups.removeSubrange((index + 1)...)
        
        // Get the user message content from the group right above
        let userContent = groups[index - 1].activeConversation.content
        
        // Add a new conversation to the assistant group
        let newAssistantConversation = Conversation(role: .assistant, content: "", model: config.model)
        assistantGroup.addConversation(newAssistantConversation)
        
        // Trigger the regeneration
        Task {
            await sendInput(isRegen: true, regenContent: userContent)
        }
    }

    func stopStreaming() {
        streamingTask?.cancel()
        
        if let last = groups.last {
            if last.activeConversation.content.isEmpty {
                deleteConversationGroup(last)
            } else {
                last.activeConversation.isReplying = false
            }
        }
    }
    
    func resetContext(at group: ConversationGroup) {
        if let index = groups.firstIndex(where: { $0 == group }) {
            let newResetMarker = (resetMarker == index) ? nil : index
            
            if index == groups.count - 1 {
                resetMarker = newResetMarker
            } else {
                withAnimation {
                    resetMarker = newResetMarker
                }
            }
        }
    }

    
    func fork(from group: ConversationGroup) -> Session {
        let newSession = Session(config: config.copy() as! SessionConfig)
        newSession.title = title
        
        let groupsToCopy = groups.prefix(through: groups.firstIndex(of: group)!)
        newSession.groups = groupsToCopy.map { $0.copy() as! ConversationGroup }
        
        return newSession
    }
    
    @discardableResult
    func addConversationGroup(conversation: Conversation) -> Conversation {
        let group = ConversationGroup(conversation: conversation, session: self)

        groups.append(group)
        return conversation
    }
    
    func deleteConversation(at indexSet: IndexSet) {
        groups.remove(atOffsets: indexSet)
        if groups.count == 0 {
            errorMessage = ""
        }
    }
    
    func deleteConversationGroup(_ conversationGroup: ConversationGroup) {
        groups.removeAll(where: { $0 == conversationGroup })
        if groups.count == 0 {
            errorMessage = ""
        }
    }
    
    func deleteAllConversations() {
        groups.removeAll()
        errorMessage = ""
    }
    
    func moveConversation(from source: IndexSet, to destination: Int) {
        groups.move(fromOffsets: source, toOffset: destination)
    }
}


