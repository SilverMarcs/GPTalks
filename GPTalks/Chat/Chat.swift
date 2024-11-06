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
    var isStarred: Bool = false // TODO: enum for archive and recently deleted and quick
    var errorMessage: String = ""
    var isQuick: Bool = false
    var tokenCount: Int = 0
    
    @Relationship(deleteRule: .cascade)
    var unorderedThreads =  [Thread]()
    
    var threads: [Thread] {
        get {return unorderedThreads.sorted(by: {$0.date < $1.date})}
        set { unorderedThreads = newValue }
    }
    
    @Relationship(deleteRule: .cascade)
    var config: ChatConfig
    
    @Transient
    var proxy: ScrollViewProxy?
    
    @Attribute(.ephemeral)
    var hasUserScrolled: Bool = false
    
    @Attribute(.ephemeral)
    var showCamera: Bool = false
    
    @Transient
    var isReplying: Bool {
        threads.last?.isReplying ?? false
    }
    
    @Transient
    var streamingTask: Task<Void, Error>?
    
    @Transient
    var isStreaming: Bool {
        streamingTask != nil
    }
    
    @Transient
    var streamer: StreamHandler?
    
    @Transient
    var inputManager = InputManager()
    
    init(config: ChatConfig) {
        self.config = config
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        scrollBottom()
        hasUserScrolled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Float.UIIpdateInterval) {
            if let lastThread = self.threads.last, lastThread.content.isEmpty {
                self.deleteThread(lastThread)
            }
        }
    }

    @MainActor
    func processRequest() async {
        streamingTask = Task {
            streamer = .init(session: self)
            try await streamer?.handleRequest()
            
            // will the following lines only be executed after processRequest is done?
            streamingTask?.cancel()
            streamingTask = nil
//            self.refreshTokens() // TODO: make async
        }
        
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
    
    @MainActor
    func sendInput() async {
        errorMessage = ""
        self.date = Date()

        guard !inputManager.prompt.isEmpty else { return }

        if inputManager.state == .editing {
            await handleEditing()
        } else {
            await handleNewInput()
        }

        if AppConfig.shared.autogenTitle {
            Task { await generateTitle() }
        }
    }

    @MainActor
    private func handleEditing() async {
        guard let index = inputManager.editingIndex else { return }
        let editingMessage = threads[index]
        editingMessage.content = inputManager.prompt
        editingMessage.dataFiles = inputManager.dataFiles
        inputManager.reset()
        await regenerate(thread: editingMessage)
    }

    @MainActor
    private func handleNewInput() async {
        let user = Thread(role: .user, content: inputManager.prompt, dataFiles: inputManager.dataFiles)
        addThread(user)
        inputManager.reset()
        await processRequest()
    }
    
    @MainActor
    func regenerate(thread: Thread) async {
        guard let index = threads.firstIndex(where: { $0 == thread }) else { return }
        threads.removeSubrange(thread.role == .assistant ? index... : (index + 1)...)
        await processRequest()
    }
    
    func stopStreaming() {
        hasUserScrolled = false
        streamingTask?.cancel()
        streamingTask = nil
        
        if let last = threads.last {
            last.isReplying = false
            if last.content.isEmpty {
                deleteThread(last)
            }
        } else {
            threads.last.map(deleteThread)
        }
    }
    
//    @MainActor
    func generateTitle(forced: Bool = false) async {
        guard !isQuick else { return }
        guard forced || threads.count <= 2 else { return }
        
        if let newTitle = await TitleGenerator.generateTitle(threads: threads, provider: config.provider) {
            self.title = newTitle
        }
    }
    
    func refreshTokens() {
        let messageTokens = threads.reduce(0) { $0 + $1.tokenCount}
        let sysPromptTokens = countTokensFromText(config.systemPrompt)
        let toolTokens = config.tools.tokenCount
        let inputTokens = countTokensFromText(inputManager.prompt)
        
        self.tokenCount = (messageTokens + sysPromptTokens + toolTokens + inputTokens)
    }
    
    func copy(from thread: Thread? = nil, purpose: ChatConfigPurpose) async -> Chat {
        let newSession = Chat(config: config.copy(purpose: purpose))
        
        let leading = switch purpose {
            case .chat: "Ψ"
            case .quick: "↯"
            case .title: "T"
        }
        
        newSession.title = "\(leading) \(self.title)"
        
        if let thread = thread, let index = threads.firstIndex(of: thread) {
            newSession.threads = threads.prefix(through: index).map { $0.copy() }
        } else {
            newSession.threads = threads.map { $0.copy() }
        }
        
        return newSession
    }

    
    func addThread(_ thread: Thread) {
        if thread.role == .assistant {
            thread.isReplying = true
        }
        
        thread.chat = self
        
        threads.append(thread)
        scrollBottom()
        
        try? modelContext?.save()
    }
    
    func scrollBottom() {
        if let proxy = self.proxy, !hasUserScrolled {
            scrollToBottom(proxy: proxy)
        }
    }
    
    // TODO: make async
    func deleteThread(_ thread: Thread) {
        threads.removeAll(where: { $0 == thread })
        // TOOD: put all in single thread.
//
//        if let index = groups.firstIndex(of: conversationGroup) {
//            if conversationGroup.role == .assistant {
//                var groupsToDelete = [conversationGroup]
//                
//                // Iterate backwards from the index of the group to be deleted
//                for i in stride(from: index - 1, through: 0, by: -1) {
//                    let previousGroup = groups[i]
//                    if previousGroup.role == .user {
//                        break // Stop when we encounter a user role
//                    }
//                    groupsToDelete.append(previousGroup)
//                }
//                
//                // Remove the groups from the array
//                groups.removeAll(where: { groupsToDelete.contains($0) })
//                
//                
//                // Delete the groups from the model context
//                for group in groupsToDelete {
//                    self.modelContext?.delete(group)
//                }
//            } else {
//                // If it's not an assistant role, just delete the single group
//                groups.removeAll(where: { $0 == conversationGroup })
//                
//                self.modelContext?.delete(conversationGroup)
//            }
//        }
        self.refreshTokens()
    }

    
    func deleteAllThreads() {
        while let thread = threads.popLast() {
            self.modelContext?.delete(thread)
        }
        
        errorMessage = ""
        self.refreshTokens()
    }
}
