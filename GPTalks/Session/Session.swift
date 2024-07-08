//
//  Item.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import Foundation
import SwiftData
//import SwiftUI
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
    
    @Transient
    var streamingTask: Task<Void, Error>?
    
    @Attribute(.ephemeral) 
    var isReplying: Bool {
        unorderedGroups.last?.activeConversation.isReplying ?? false
    }
    
    @Transient
    var inputManager = InputManager()

    var config: SessionConfig
    
    init(config: SessionConfig = SessionConfig()) {
        self.config = config
    }
    
    @MainActor
    func sendInput(isRegen: Bool = false, regenContent: String? = nil) async {
        errorMessage = ""
        
        if !isRegen && inputManager.prompt.isEmpty {
            return
        }
        
        self.modelContext?.autosaveEnabled = false
        self.date = Date()
        
        if !isRegen {
            let content = inputManager.prompt
            inputManager.reset()
            let user = Conversation(role: .user, content: content, model: config.model)
            addConversationGroup(conversation: user)
        }
        
        let streamingTask = Task(priority: .userInitiated) {
            try await processRequest(isRegen: isRegen, regenContent: regenContent)
        }
        
        do {
            try await streamingTask.value
            try self.modelContext?.save()
        } catch {
            print("Error: \(error)")
            errorMessage = error.localizedDescription
            
            //TODO: if last group active is empty, remove lastgroup active
        }
        
        self.modelContext?.autosaveEnabled = true
    }

    
    @MainActor
    func processRequest(isRegen: Bool, regenContent: String?) async throws {
        var streamText = ""
        let uiUpdateInterval = TimeInterval(0.1)
        var lastUIUpdateTime = Date()
        
//        var updatedConversationGroups = conversationGroups
        var updatedConversationGroups = groups.map { $0.copy() as! ConversationGroup }
        
        if isRegen {
            // Remove the last assistant message from the query
            if let lastIndex = updatedConversationGroups.lastIndex(where: { $0.role == .assistant }) {
                updatedConversationGroups.remove(at: lastIndex)
            }
            
            // Add the regen content if available
            if let regenContent = regenContent,
               let lastUserGroupIndex = updatedConversationGroups.lastIndex(where: { $0.role == .user }) {
                let regenUserConversation = Conversation(role: .user, content: regenContent, model: config.model)
                updatedConversationGroups[lastUserGroupIndex] = ConversationGroup(conversation: regenUserConversation)
            }
        }
        
        let stream = StreamManager.streamResponse(from: updatedConversationGroups, config: config)
        
        let assistant: Conversation
        if isRegen {
            assistant = Conversation(role: .assistant, content: "", model: config.model)
            assistant.isReplying = true
            if let lastAssistantGroup = groups.last(where: { $0.role == .assistant }) {
                // Add a new conversation to the existing assistant group
                lastAssistantGroup.addConversation(assistant)
            } else {
                // Create a new assistant group
                addConversationGroup(conversation: assistant)
            }
        } else {
            assistant = Conversation(role: .assistant, content: "", model: config.model)
            assistant.isReplying = true
            addConversationGroup(conversation: assistant)
        }
        
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


    func regenerateLast() {
        guard let lastGroup = unorderedGroups.last else {
            return
        }
        
        let userContent: String
        if lastGroup.role == .user {
            userContent = lastGroup.activeConversation.content
        } else if let secondLastGroup = groups.dropLast().last, secondLastGroup.role == .user {
            userContent = secondLastGroup.activeConversation.content
        } else {
            return // No user message to regenerate
        }
        
        // Trigger the regeneration
        Task {
            await sendInput(isRegen: true, regenContent: userContent)
        }
    }
    
    func resetContext(at group: ConversationGroup) {
        if let index = unorderedGroups.firstIndex(where: { $0 == group }) {
            if resetMarker == index {
                resetMarker = nil
            } else {
                resetMarker = index
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
//        conversation.group = group

        groups.append(group)
        return conversation
    }
    
    func deleteConversation(at indexSet: IndexSet) {
        groups.remove(atOffsets: indexSet)
    }
    
    func deleteConversationGroup(_ conversationGroup: ConversationGroup) {
        groups.removeAll(where: { $0 == conversationGroup })
    }
    
    func deleteAllConversations() {
        groups.removeAll()
    }
    
    func moveConversation(from source: IndexSet, to destination: Int) {
        groups.move(fromOffsets: source, toOffset: destination)
    }
}


