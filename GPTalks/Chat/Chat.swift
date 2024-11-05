//
//  Item.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftData
import SwiftUI

@Model
final class Chat {
    var id: UUID = UUID()
    var date: Date = Date()
    var title: String = "Chat Session"
    var isStarred: Bool = false // TODO: enum for archive and recently deleted
    var errorMessage: String = ""
    var isQuick: Bool = false
    var tokenCount: Int = 0
    
    @Relationship(deleteRule: .cascade, inverse: \ThreadGroup.session)
    var unorderedGroups =  [ThreadGroup]()
    
    @Relationship(deleteRule: .cascade)
    var config: ChatConfig
    
    @Transient
    var groups: [ThreadGroup] {
        get {return unorderedGroups.sorted(by: {$0.date < $1.date})}
        set { unorderedGroups = newValue }
    }
    
    @Transient
    var streamingTask: Task<Void, Error>?
    
//    @Transient
    var isStreaming: Bool {
        streamingTask != nil
    }
    
    @Transient
    var proxy: ScrollViewProxy?
    
    @Attribute(.ephemeral)
    var hasUserScrolled: Bool = false
    
    @Attribute(.ephemeral)
    var showCamera: Bool = false
    
//    @Transient
    var isReplying: Bool {
        groups.last?.activeThread.isReplying ?? false
    }
    
    @Transient
    var streamer: StreamHandler?
    
    @Transient
    var inputManager = InputManager()
    
    init(config: ChatConfig) {
        self.config = config
    }
    
    @MainActor
    private func handleStreamingTask(regenContent: String?, assistantGroup: ThreadGroup?) async throws {
        try await processRequest(regenContent: regenContent, assistantGroup: assistantGroup)
        
        streamingTask?.cancel()
        streamingTask = nil
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        scrollBottom()
        hasUserScrolled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Float.UIIpdateInterval) {
            if let lastGroup = self.groups.last, lastGroup.activeThread.content.isEmpty {
                lastGroup.deleteThread(lastGroup.activeThread)
                if !lastGroup.conversations.isEmpty {
                    lastGroup.activeThreadIndex -= 1
                }
            }
        }
    }
    
    @MainActor
    private func processRequest(regenContent: String?, assistantGroup: ThreadGroup?) async throws {
        let conversations = prepareThreads(regenContent: regenContent)
        let assistant = prepareAssistantThread(assistantGroup: assistantGroup)
        
        self.streamer = StreamHandler(conversations: conversations, session: self, assistant: assistant)
        if let streamer = streamer {
            try await streamer.handleRequest()
        }
    }
    
    private func prepareAssistantThread(assistantGroup: ThreadGroup?) -> Thread {
        if let assistantGroup = assistantGroup {
            return assistantGroup.conversations.last!
        } else {
            let assistant = Thread(role: .assistant, content: "", provider: config.provider, model: config.model)
            addThreadGroup(conversation: assistant)
            return assistant
        }
    }
    
    private func prepareThreads(regenContent: String?) -> [Thread] {
        var conversations = groups.map { group -> Thread in
            let conversation = group.activeThread
            
            let textContent = conversation.dataFiles
                .compactMap { $0.formattedTextContent }
                .joined(separator: "\n\n")
            
            if !textContent.isEmpty {
                conversation.content = textContent + "\n\n" + conversation.content
            }
            
            return conversation
        }
        
        if let regenContent = regenContent {
            if let lastUserIndex = conversations.lastIndex(where: { $0.role == .user }) {
                let existingDataFiles = conversations[lastUserIndex].dataFiles
                conversations[lastUserIndex] = Thread(role: .user, content: regenContent, dataFiles: existingDataFiles)
            }
            if let lastAssistantIndex = conversations.lastIndex(where: { $0.role == .assistant }) {
                conversations.remove(at: lastAssistantIndex)
            }
        }
        
        return conversations
    }

    
    @MainActor
    func sendInput(isRegen: Bool = false, regenContent: String? = nil, assistantGroup: ThreadGroup? = nil, forQuick: Bool = false) async {
        errorMessage = ""
        self.date = Date()
        
        if !isRegen {
            if inputManager.state == .editing {
                handleEditingMode()
            } else {
                guard !inputManager.prompt.isEmpty else { return }
                
                let content = inputManager.prompt
                let dataFiles = inputManager.dataFiles
                inputManager.reset()
                
                let user = Thread(role: .user, content: content, dataFiles: dataFiles)
                addThreadGroup(conversation: user)
            }
        }
        
        if AppConfig.shared.autogenTitle {
            Task { await generateTitle() }
        }
        
        streamingTask = Task {
            try await handleStreamingTask(regenContent: regenContent, assistantGroup: assistantGroup)
            self.refreshTokens()
        }
        
        // TODO: create func for this
        do {
            #if os(macOS)
            try await streamingTask?.value
            #else
            let application = UIApplication.shared
            let taskId = application.beginBackgroundTask {
                // Handle expiration of background task here
            }
            
            try await streamingTask?.value
            
            application.endBackgroundTask(taskId)
            #endif
        } catch {
            handleError(error)
        }
    }
    
    private func handleEditingMode() {
        if let editingIndex = inputManager.editingIndex,
           editingIndex < groups.count,
           groups[editingIndex].activeThread.role == .user {

            
            groups[editingIndex].activeThread.content = inputManager.prompt
            groups[editingIndex].activeThread.dataFiles = inputManager.dataFiles
            
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
    func regenerate(group: ThreadGroup) async {
        guard group.role == .assistant else { return }
        
        guard let index = groups.firstIndex(where: { $0.id == group.id }),
              index > 0 else { return }
        
        let userGroup = groups[index - 1]
        let userContent = userGroup.activeThread.content
        
        let newAssistantThread = Thread(role: .assistant, content: "", provider: config.provider, model: config.model)
        group.addThread(newAssistantThread)
        
        groups.removeSubrange((index + 1)...)
        
        await sendInput(isRegen: true, regenContent: userContent, assistantGroup: group)
    }
    
    @MainActor
    func stopStreaming() {
        hasUserScrolled = false
        streamingTask?.cancel()
        streamingTask = nil
        
        if let last = groups.last {
            if last.activeThread.content.isEmpty {
                deleteThreadGroup(last)
            } else {
                last.activeThread.isReplying = false
            }
        }
    }
    
    @MainActor
    func generateTitle(forced: Bool = false) async {
        if isQuick { return }
        
        if forced || groups.count == 1 || groups.count == 2 {
            if let newTitle = await TitleGenerator.generateTitle(adjustedGroups: groups, provider: config.provider) {
                self.title = newTitle
            }
        }
    }
    
    func refreshTokens() {
        let messageTokens = groups.reduce(0) { $0 + $1.tokenCount}
        let sysPromptTokens = countTokensFromText(config.systemPrompt)
        let toolTokens = config.tools.tokenCount
        let inputTokens = countTokensFromText(inputManager.prompt)
        
        self.tokenCount = (messageTokens + sysPromptTokens + toolTokens + inputTokens)
    }
    
    func copy(from group: ThreadGroup? = nil, purpose: ChatConfigPurpose) async -> Chat {
        let newSession = Chat(config: config.copy(purpose: purpose))
        let leading: String
        
        switch purpose {
            case .chat: leading = "(Ψ)"
            case .quick: leading = "↯"
            case .title: leading = "T"
        }
        
        newSession.title = leading + " " + self.title
        
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
    func addThreadGroup(conversation: Thread) -> ThreadGroup {
        let group = ThreadGroup(conversation: conversation, session: self)
        
        groups.append(group)
        
        scrollBottom()
        
        try? modelContext?.save()
        
        return group
    }
    
    func scrollBottom() {
        if let proxy = self.proxy, !hasUserScrolled {
            scrollToBottom(proxy: proxy)
        }
    }
    
    // TODO: make async
    func deleteThreadGroup(_ conversationGroup: ThreadGroup) {
        guard !groups.isEmpty else {
            errorMessage = ""
            return
        }
        
        if let index = groups.firstIndex(of: conversationGroup) {
            if conversationGroup.role == .assistant {
                var groupsToDelete = [conversationGroup]
                
                // Iterate backwards from the index of the group to be deleted
                for i in stride(from: index - 1, through: 0, by: -1) {
                    let previousGroup = groups[i]
                    if previousGroup.role == .user {
                        break // Stop when we encounter a user role
                    }
                    groupsToDelete.append(previousGroup)
                }
                
                // Remove the groups from the array
                groups.removeAll(where: { groupsToDelete.contains($0) })
                
                
                // Delete the groups from the model context
                for group in groupsToDelete {
                    self.modelContext?.delete(group)
                }
            } else {
                // If it's not an assistant role, just delete the single group
                groups.removeAll(where: { $0 == conversationGroup })
                
                self.modelContext?.delete(conversationGroup)
            }
        }
        self.refreshTokens()
    }

    
    func deleteAllThreads() {
        // Remove all conversation groups from the groups array and modelContext
        while let conversationGroup = groups.popLast() {
            self.modelContext?.delete(conversationGroup)
        }
        
        errorMessage = ""
        self.refreshTokens()
    }
}
