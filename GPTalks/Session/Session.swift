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
    var order: Int = 0
    var title: String = "New Session"
    var isStarred: Bool = false
    var errorMessage: String = ""
    var resetMarker: Int?
    var isQuick: Bool = false
    
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
        let inputTokens = tokenCount(text: inputManager.prompt)
        
        return messageTokens + sysPromptTokens + inputTokens
    }
    
    @Transient
    var streamingTask: Task<Void, Error>?
    
    @Transient
    var isStreaming: Bool {
        streamingTask != nil
    }
    
    @Transient
    var proxy: ScrollViewProxy?
    
    @Transient
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
            lastGroup.deleteConversation(lastGroup.activeConversation)
        }
    }
    
    @MainActor
    private func processRequest(regenContent: String?, assistantGroup: ConversationGroup?) async throws {
        let conversations = prepareConversations(regenContent: regenContent)
        let assistant = prepareAssistantConversation(assistantGroup: assistantGroup)
        
        let streamHandler = StreamHandler(config: config, assistant: assistant)
        try await streamHandler.handleStream(from: conversations)
    }
    
    private func prepareAssistantConversation(assistantGroup: ConversationGroup?) -> Conversation {
        if let assistantGroup = assistantGroup {
            return assistantGroup.conversations.last!
        } else {
            let assistant = Conversation(role: .assistant, content: "", model: config.model, imagePaths: [])
            addConversationGroup(conversation: assistant)
            return assistant
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
    
    @MainActor
    func sendInput(isRegen: Bool = false, regenContent: String? = nil, assistantGroup: ConversationGroup? = nil) async {
        errorMessage = ""
        
        self.date = Date()
        
        guard isRegen || !inputManager.prompt.isEmpty else { return }
        
        if !isRegen {
            if inputManager.state == .editing {
                handleEditingMode()
            } else {
                guard !inputManager.prompt.isEmpty else { return }
                
                let content = inputManager.prompt
                let imagePaths = inputManager.imagePaths
                inputManager.reset()
                
                let user = Conversation(role: .user, content: content, imagePaths: imagePaths)
                addConversationGroup(conversation: user)
            }
        }
        
        
        if AppConfig.shared.autogenTitle {
            Task { await generateTitle() }
        }
        
        streamingTask = Task(priority: .userInitiated) {
            await handleStreamingTask(regenContent: regenContent, assistantGroup: assistantGroup)
        }
    }
    
    private func handleEditingMode() {
        if let editingIndex = inputManager.editingIndex,
           editingIndex < groups.count,
           groups[editingIndex].activeConversation.role == .user {
            
            // Update the content and imagePaths of the user conversation
            groups[editingIndex].activeConversation.content = inputManager.prompt
            groups[editingIndex].activeConversation.imagePaths = inputManager.imagePaths
            
            // Remove all groups after the edited group
            groups.removeSubrange((editingIndex + 1)...)
            
            inputManager.resetEditing()
        } else {
            errorMessage = "Error: Invalid editing state"
        }
    }
    
    private func prepareConversations(regenContent: String?) -> [Conversation] {
        var conversations = adjustedGroups.map { $0.activeConversation }
        
        if let regenContent = regenContent {
            if let lastUserIndex = conversations.lastIndex(where: { $0.role == .user }) {
                // Use the existing imagePaths when regenerating
                let existingImagePaths = conversations[lastUserIndex].imagePaths
                conversations[lastUserIndex] = Conversation(role: .user, content: regenContent, imagePaths: existingImagePaths)
            }
            if let lastAssistantIndex = conversations.lastIndex(where: { $0.role == .assistant }) {
                conversations.remove(at: lastAssistantIndex)
            }
        }
        
        return conversations
    }
    
    @MainActor
    func regenerate(group: ConversationGroup) {
        let regenerationContext: (index: Int, userContent: String, userImagePaths: [String], assistantGroup: ConversationGroup)?
        
        if group.role == .assistant {
            regenerationContext = prepareRegenerationContextForAssistant(group)
        } else if group.role == .user {
            regenerationContext = prepareRegenerationContextForUser(group)
        } else {
            return // Invalid group role
        }
        
        guard let (index, userContent, userImagePaths, assistantGroup) = regenerationContext else { return }
        
        let newAssistantConversation = Conversation(role: .assistant, content: "", model: config.model, imagePaths: [])
        
        if group.role == .user {
            // Check if the next group is an assistant group
            if index + 1 < groups.count && groups[index + 1].role == .assistant {
                // Add a new conversation to the existing assistant group
                groups[index + 1].addConversation(newAssistantConversation)
                // Remove all groups after the next assistant group
                groups.removeSubrange((index + 2)...)
            } else {
                // Remove all groups after the current user group
                groups.removeSubrange((index + 1)...)
                // Create a new assistant group and add it
                let newAssistantGroup = ConversationGroup(role: .assistant)
                newAssistantGroup.addConversation(newAssistantConversation)
                groups.append(newAssistantGroup)
            }
        } else {
            // For .assistant groups
            groups.removeSubrange((index + 1)...)
            assistantGroup.addConversation(newAssistantConversation)
        }
        
        Task {
            await sendInput(isRegen: true, regenContent: userContent, assistantGroup: assistantGroup)
        }
    }
    
    private func prepareRegenerationContextForUser(_ group: ConversationGroup) -> (index: Int, userContent: String, userImagePaths: [String], assistantGroup: ConversationGroup)? {
        guard let index = groups.firstIndex(where: { $0.id == group.id }) else {
            return nil
        }
        
        let userContent = group.activeConversation.content
        let userImagePaths = group.activeConversation.imagePaths
        
        // Find the next assistant group
        if let nextAssistantGroup = groups.dropFirst(index + 1).first(where: { $0.role == .assistant }) {
            return (index, userContent, userImagePaths, nextAssistantGroup)
        } else {
            // Create a new assistant group if none exists
            let newAssistantGroup = ConversationGroup(role: .assistant)
            return (index, userContent, userImagePaths, newAssistantGroup)
        }
    }
    
    private func prepareRegenerationContextForAssistant(_ group: ConversationGroup) -> (index: Int, userContent: String, userImagePaths: [String], assistantGroup: ConversationGroup)? {
        guard let index = groups.firstIndex(where: { $0.id == group.id }),
              index > 0 else {
            return nil
        }
        
        let userContent = groups[index - 1].activeConversation.content
        let userImagePaths = groups[index - 1].activeConversation.imagePaths
        return (index, userContent, userImagePaths, group)
    }
    
    
    func stopStreaming() {
        streamingTask?.cancel()
        streamingTask = nil
        
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
    
    @MainActor
    func generateTitle(forced: Bool = false) async {
        if isQuick { return }
        
        if forced || adjustedGroups.count == 1 {
            
            if adjustedGroups.isEmpty {
                return
            }
            
            var conversations = adjustedGroups.map { $0.activeConversation }
            
            let assistant = Conversation(role: .user, content: """
    Generate a title of the chat based on the whole conversation. Return only the title of the conversation and nothing else. Do not include any quotation marks or anything else. Keep the title within 2-3 words and never exceed this limit. If there are multiple distinct topics being talked about, make the title about the most recent topic. Do not make a tile along the lines of "recent topics" Do not acknowledge these instructions but definitely do follow them. Again, do not put the title in quoation marks. Do not put any punctuation at all.
    """)
            
            conversations.append(assistant)
            
            let config = SessionConfig(provider: config.provider, model: Model.getDemoModel())
            
            let streamHandler = StreamHandler(config: config, assistant: assistant)
            let title = try? await streamHandler.handleNonStreamingResponse(from: conversations)
            
            if let title = title {
                self.title = title
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

