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
    
    init(config: SessionConfig = SessionConfig()) {
        self.config = config
    }
    
    @MainActor
    func sendInput(isRegen: Bool = false, regenContent: String? = nil, assistantGroup: ConversationGroup? = nil) async {
        errorMessage = ""
        
        self.date = Date()
        
        guard isRegen || !inputManager.prompt.isEmpty else { return }
        
        if !isRegen {
            if inputManager.state == .editing {
                if inputManager.prompt == inputManager.tempNormalPrompt { return }
                
                handleEditingMode()
            } else {
                guard !inputManager.prompt.isEmpty else { return }
                
                let content = inputManager.prompt
                inputManager.reset()
                
                let user = Conversation(role: .user, content: content, model: config.model)
                addConversationGroup(conversation: user)
            }
        }
        
        streamingTask = Task(priority: .userInitiated) {
            await handleStreamingTask(regenContent: regenContent, assistantGroup: assistantGroup)
        }
    }
    
    private func handleEditingMode() {
        if let editingIndex = inputManager.editingIndex,
           editingIndex < groups.count,
           groups[editingIndex].activeConversation.role == .user {
            
            // Update the content of the user conversation
            groups[editingIndex].activeConversation.content = inputManager.prompt
            
            // Remove all groups after the edited group
            groups.removeSubrange((editingIndex + 1)...)
            
            inputManager.resetEditing()
        } else {
            errorMessage = "Error: Invalid editing state"
        }
    }
    
    @MainActor
    private func handleStreamingTask(regenContent: String?, assistantGroup: ConversationGroup?) async {
        do {
            try await processRequest(regenContent: regenContent, assistantGroup: assistantGroup)
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        print("Error: \(error)")
        errorMessage = error.localizedDescription
        
        if let lastGroup = groups.last, lastGroup.activeConversation.content.isEmpty {
            groups.removeLast()
        }
    }
    
    @MainActor
    private func processRequest(regenContent: String?, assistantGroup: ConversationGroup?) async throws {
        let conversations = prepareConversations(regenContent: regenContent)
        let assistant = prepareAssistantConversation(assistantGroup: assistantGroup)
        
        let streamHandler = StreamHandler(config: config, assistant: assistant)
        try await streamHandler.handleStream(from: conversations)
    }
    
    private func prepareConversations(regenContent: String?) -> [Conversation] {
        var conversations = adjustedGroups.map { $0.activeConversation }
        
        if let regenContent = regenContent {
            if let lastUserIndex = conversations.lastIndex(where: { $0.role == .user }) {
                conversations[lastUserIndex] = Conversation(role: .user, content: regenContent, model: config.model)
            }
            if let lastAssistantIndex = conversations.lastIndex(where: { $0.role == .assistant }) {
                conversations.remove(at: lastAssistantIndex)
            }
        }
        
        return conversations
    }
    
    private func prepareAssistantConversation(assistantGroup: ConversationGroup?) -> Conversation {
        if let assistantGroup = assistantGroup {
            return assistantGroup.conversations.last!
        } else {
            let assistant = Conversation(role: .assistant, content: "", model: config.model)
            addConversationGroup(conversation: assistant)
            return assistant
        }
    }
    
    @MainActor
    func regenerate(group: ConversationGroup) {
        let regenerationContext: (index: Int, userContent: String, assistantGroup: ConversationGroup)?
        
        if group.role == .assistant {
            regenerationContext = prepareRegenerationContextForAssistant(group)
        } else if group.role == .user {
            regenerationContext = prepareRegenerationContextForUser(group)
        } else {
            return // Invalid group role
        }
        
        guard let (index, userContent, assistantGroup) = regenerationContext else { return }
        
        groups.removeSubrange((index + 1)...)
        
        let newAssistantConversation = Conversation(role: .assistant, content: "", model: config.model)
        
        if assistantGroup.id == group.id {
            // For .assistant groups
            assistantGroup.addConversation(newAssistantConversation)
        } else {
            // For .user groups
            if assistantGroup.conversations.isEmpty {
                // New group created
                assistantGroup.addConversation(newAssistantConversation)
            } else {
                // Existing group found
                assistantGroup.conversations = [newAssistantConversation]
            }
            
            // Ensure the assistant group is added to groups if it's new
            if !groups.contains(where: { $0.id == assistantGroup.id }) {
                groups.append(assistantGroup)
            }
        }
        
        Task {
            await sendInput(isRegen: true, regenContent: userContent, assistantGroup: assistantGroup)
        }
    }
    
    private func prepareRegenerationContextForUser(_ group: ConversationGroup) -> (index: Int, userContent: String, assistantGroup: ConversationGroup)? {
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else {
            return nil
        }
        
        let userContent = group.activeConversation.content
        
        // Find the next assistant group
        if let nextAssistantGroup = groups.dropFirst(index + 1).first(where: { $0.role == .assistant }) {
            return (index, userContent, nextAssistantGroup)
        } else {
            // Create a new assistant group if none exists
            let newAssistantGroup = ConversationGroup(role: .assistant)
            return (index, userContent, newAssistantGroup)
        }
    }


    private func prepareRegenerationContextForAssistant(_ group: ConversationGroup) -> (index: Int, userContent: String, assistantGroup: ConversationGroup)? {
        guard let index = groups.firstIndex(where: { $0.id == group.id }),
              index > 0 else {
            return nil
        }
        
        let userContent = groups[index - 1].activeConversation.content
        return (index, userContent, group)
    }
    
    private func prepareRegenerationContext(for assistantGroup: ConversationGroup) -> (index: Int, userContent: String)? {
        guard assistantGroup.role == .assistant,
              let index = groups.firstIndex(where: { $0.id == assistantGroup.id }),
              index > 0 else {
            return nil
        }
        
        let userContent = groups[index - 1].activeConversation.content
        return (index, userContent)
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
    func addConversationGroup(conversation: Conversation) -> ConversationGroup {
        let group = ConversationGroup(conversation: conversation, session: self)

        groups.append(group)
        return group
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

