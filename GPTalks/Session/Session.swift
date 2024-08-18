//
//  Item.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Session {
    var id: UUID = UUID()
    var date: Date = Date()
    var order: Int = 0
    var title: String = "Chat Session"
    var isStarred: Bool = false
    var errorMessage: String = ""
    var resetMarker: Int?
    var isQuick: Bool = false
    var tokenCount: Int = 0
    
    var folder: Folder?
    
    @Relationship(deleteRule: .cascade, inverse: \ConversationGroup.session)
    var unorderedGroups =  [ConversationGroup]()
    
    @Relationship(deleteRule: .nullify, inverse: \SessionConfig.session)
    var config: SessionConfig
    
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
    
    @Attribute(.ephemeral)
    var searchText: String = ""
    
    @Transient
    var inputManager = InputManager()
    
    init(config: SessionConfig) {
        self.config = config
    }
    
    @MainActor
    private func handleStreamingTask(regenContent: String?, assistantGroup: ConversationGroup?) async {
        do {
            try await processRequest(regenContent: regenContent, assistantGroup: assistantGroup)
        } catch {
            handleError(error)
        }
        streamingTask?.cancel()
        streamingTask = nil
    }
    
    private func handleError(_ error: Error) {
        print("Error: \(error)")
        errorMessage = error.localizedDescription
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Float.UIIpdateInterval) {
            if let lastGroup = self.groups.last, lastGroup.activeConversation.content.isEmpty {
                lastGroup.deleteConversation(lastGroup.activeConversation)
            }
            
            if let proxy = self.proxy {
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    @MainActor
    private func processRequest(regenContent: String?, assistantGroup: ConversationGroup?) async throws {
        let conversations = prepareConversations(regenContent: regenContent)
        let assistant = prepareAssistantConversation(assistantGroup: assistantGroup)
        
        let streamHandler = StreamHandler(config: config, assistant: assistant)
        try await streamHandler.handleRequest(from: conversations)
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
    
    private func prepareConversations(regenContent: String?) -> [Conversation] {
        var conversations = adjustedGroups.map { $0.activeConversation }
        
        if let regenContent = regenContent {
            if let lastUserIndex = conversations.lastIndex(where: { $0.role == .user }) {
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
    func sendInput(isRegen: Bool = false, regenContent: String? = nil, assistantGroup: ConversationGroup? = nil) async {
        errorMessage = ""
        self.order = 0
        self.date = Date()
        
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
                
//                #if DEBUG
//                addConversationGroup(conversation: Conversation(role: .assistant, content: .assistantDemos.randomElement()!))
//                return
//                #endif
            }
        }
        
        if AppConfig.shared.autogenTitle {
            Task { await generateTitle() }
        }
        
        streamingTask = Task(priority: .userInitiated) {
            await handleStreamingTask(regenContent: regenContent, assistantGroup: assistantGroup)
            self.refreshTokens()
        }
    }
    
    private func handleEditingMode() {
        if let editingIndex = inputManager.editingIndex,
           editingIndex < groups.count,
           groups[editingIndex].activeConversation.role == .user {
            
            groups[editingIndex].activeConversation.content = inputManager.prompt
            groups[editingIndex].activeConversation.imagePaths = inputManager.imagePaths
            
            groups.removeSubrange((editingIndex + 1)...)
            
            inputManager.resetEditing()
        } else {
            errorMessage = "Error: Invalid editing state"
            if let proxy = proxy {
                scrollToBottom(proxy: proxy)
            }
        }
    }
    
    @MainActor
    func regenerate(group: ConversationGroup) {
        guard group.role == .assistant else { return }
        
        guard let index = groups.firstIndex(where: { $0.id == group.id }),
              index > 0 else { return }
        
        let userGroup = groups[index - 1]
        let userContent = userGroup.activeConversation.content
        
        let newAssistantConversation = Conversation(role: .assistant, content: "", model: config.model, imagePaths: [])
        group.addConversation(newAssistantConversation)
        
        groups.removeSubrange((index + 1)...)
        
        Task {
            await sendInput(isRegen: true, regenContent: userContent, assistantGroup: group)
        }
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
                if let proxy = proxy {
                    scrollToBottom(proxy: proxy)
                }
            } else {
                resetMarker = newResetMarker
            }
        }
    }
    
    @MainActor
    func generateTitle(forced: Bool = false) async {
        if isQuick { return }
        
        if forced || adjustedGroups.count == 1 || adjustedGroups.count == 2 {
            if let newTitle = await TitleGenerator.generateTitle(adjustedGroups: adjustedGroups, provider: config.provider) {
                self.title = newTitle
            }
        }
    }
    
    func refreshTokens() {
        let messageTokens = adjustedGroups.reduce(0) { $0 + $1.activeConversation.countTokens() }
        let sysPromptTokens = countTokensFromText(text: config.systemPrompt)
        let inputTokens = countTokensFromText(text: inputManager.prompt)
        
        self.tokenCount = (messageTokens + sysPromptTokens + inputTokens)
    }
    
    func copy(from group: ConversationGroup? = nil, purpose: SessionConfigPurpose) -> Session {
        let newSession = Session(config: config.copy(purpose: purpose))
        newSession.title = purpose.title
        
        if let group = group, let index = groups.firstIndex(of: group) {
            // Scenario 1: Fork from a particular group
            let groupsToCopy = groups.prefix(through: index)
            newSession.groups = groupsToCopy.map { $0.copy()}
        } else {
            // Scenario 2: Fork all groups
            newSession.groups = groups.map { $0.copy()}
        }
        
        return newSession
    }
    
    @discardableResult
    func addConversationGroup(conversation: Conversation) -> ConversationGroup {
        let group = ConversationGroup(conversation: conversation, session: self)
        
        groups.append(group)
        return group
    }
    
    func deleteConversationGroup(_ conversationGroup: ConversationGroup) {
        if groups.count == 0 {
            errorMessage = ""
        }
//        withAnimation {
            groups.removeAll(where: { $0 == conversationGroup })
//        } completion: {
            self.modelContext?.delete(conversationGroup)
            self.refreshTokens()
//        }
    }
    
    func deleteAllConversations() {
//        withAnimation {
            groups.removeAll()
            errorMessage = ""
//        } completion: {
            self.refreshTokens()
//        }
    }
}
