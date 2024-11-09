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
    var errorMessage: String = ""
    var totalTokens: Int = 0
    
    var statusId: Int = 1 // normal status
    var status: ChatStatus {
        get { ChatStatus(rawValue: statusId)! }
        set { statusId = newValue.id }
    }
    
    @Relationship(deleteRule: .cascade)
    var unorderedThreads =  [Thread]()
    var threads: [Thread] {
        get { return unorderedThreads.sorted(by: {$0.date < $1.date})}
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
    var streamingTask: Task<Void, Error>?
    @Transient
    var isReplying: Bool {
        threads.last?.isReplying ?? false
    }

    @Transient
    var inputManager = InputManager()
    
    init(config: ChatConfig) {
        self.config = config
    }
    
    @MainActor
    func processRequest() async {
        errorMessage = ""
        date = Date()
        streamingTask = Task {
            let streamer = StreamHandler(session: self)
            
            // Request background task before starting network operations
            #if !os(macOS)
            let backgroundTaskId = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?.streamingTask?.cancel()
            }
            
            defer {
                // Ensure we end the background task when done
                UIApplication.shared.endBackgroundTask(backgroundTaskId)
            }
            #endif
            
            do {
                try await streamer.handleRequest()
            } catch {
                handleError(error)
            }
            
            streamingTask?.cancel()
            streamingTask = nil
        }
        
        if AppConfig.shared.autogenTitle {
            Task { await generateTitle() }
        }
    }
    
    @MainActor
    func sendInput() async {
        errorMessage = ""
        
        guard !inputManager.prompt.isEmpty else { return }

        if inputManager.state == .editing {
            await handleEditing()
        } else {
            await handleNewInput()
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
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        scrollBottom()
        hasUserScrolled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Float.UIIpdateInterval) {
            if let lastThread = self.threads.last, lastThread.content.isEmpty, lastThread.role == .assistant {
                self.deleteThread(lastThread)
            }
        }
    }
    
    func generateTitle(forced: Bool = false) async {
        guard status != .quick else { return }
        guard forced || threads.count <= 2 else { return }
        
        if let newTitle = await TitleGenerator.generateTitle(threads: threads, provider: config.provider) {
            self.title = newTitle
        }
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
    
    func deleteThread(_ thread: Thread) {
        threads.removeAll(where: { $0 == thread })
        if threads.count == 0 {
            errorMessage = ""
        }
        modelContext?.delete(thread)
        try? modelContext?.save()
    }

    func deleteAllThreads() {
        errorMessage = ""
        while let thread = threads.popLast() {
            modelContext?.delete(thread)
        }
        try? modelContext?.save()
    }
    
    
    func copy(from thread: Thread? = nil, purpose: ChatConfigPurpose) async -> Chat {
        let newSession = Chat(config: config.copy(purpose: purpose))
        
        let leading = switch purpose {
            case .chat: "Ψ"
            case .quick: "↯"
            case .title: "T"
        }
        
        newSession.title = "\(leading) \(self.title)"
        newSession.totalTokens = self.totalTokens
        
        if let thread = thread, let index = threads.firstIndex(of: thread) {
            newSession.threads = threads.prefix(through: index).map { $0.copy() }
        } else {
            newSession.threads = threads.map { $0.copy() }
        }
        
        return newSession
    }
}
