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
    
    @Relationship(deleteRule: .cascade)
    var config: SessionConfig
    
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
            if let newTitle = await TitleGenerator.generateTitle(adjustedGroups: adjustedGroups, config: config) {
                self.title = newTitle
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
