//
//  ChatSessionBackup.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ChatSessionBackup: Codable {
    var id: UUID
    var date: Date
    var title: String
    var isStarred: Bool
    var errorMessage: String
    var resetMarker: Int?
    var groups: [ConversationGroupBackup]
    
    struct ConversationGroupBackup: Codable {
        var date: Date
        var conversation: ConversationBackup
    }
    
    struct ConversationBackup: Codable {
        var date: Date
        var content: String
        var role: ConversationRole
    }
}

extension ChatSessionBackup {
    init(from session: ChatSession) {
        self.id = session.id
        self.date = session.date
        self.title = session.title
        self.isStarred = session.isStarred
        self.errorMessage = session.errorMessage
        self.resetMarker = session.resetMarker
        self.groups = session.unorderedGroups.map { group in
            ConversationGroupBackup(
                date: group.date,
                conversation: ConversationBackup(from: group.activeConversation)
            )
        }
    }
    
    func toSession() -> ChatSession {
        var session: ChatSession
        
        let modelContext = DatabaseService.shared.modelContext
        
        var fetchDefaults = FetchDescriptor<ProviderDefaults>()
        fetchDefaults.fetchLimit = 1
        
        if let fetchedProviders = try? modelContext.fetch(fetchDefaults), let provider = fetchedProviders.first?.defaultProvider {
            session = ChatSession(config: SessionConfig(provider: provider, purpose: .chat))
        } else {
            print("Should not reach here")
            session = ChatSession(config: .mockChatConfig)
        }
        
        session.id = self.id
        session.date = self.date
        session.title = self.title
        session.isStarred = self.isStarred
        session.errorMessage = self.errorMessage
        session.resetMarker = self.resetMarker
        session.unorderedGroups = self.groups.map { groupBackup in
            let group = ConversationGroup(conversation: groupBackup.conversation.toConversation())
            group.date = groupBackup.date
            return group
        }
        return session
    }
}


extension ChatSessionBackup.ConversationBackup {
    init(from conversation: Conversation) {
        self.date = conversation.date
        self.content = conversation.content
        self.role = conversation.role
    }
    
    func toConversation() -> Conversation {
        let conversation = Conversation(role: self.role, content: self.content)
        conversation.date = self.date
        return conversation
    }
}

struct SessionsDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var sessions: [ChatSession]
    
    init(sessions: [ChatSession]) {
        self.sessions = sessions.filter { !$0.isQuick }
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.sessions = try JSONDecoder().decode([ChatSessionBackup].self, from: data).map { $0.toSession() }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(sessions.filter { !$0.isQuick }.map { ChatSessionBackup(from: $0) })
        return FileWrapper(regularFileWithContents: data)
    }
}

func restoreSessions(from url: URL) throws -> [ChatSession] {
    guard url.startAccessingSecurityScopedResource() else {
        throw NSError(domain: "FileAccessError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the security-scoped resource."])
    }
    defer {
        url.stopAccessingSecurityScopedResource()
    }
    
    do {
        let data = try Data(contentsOf: url)
        let backups = try JSONDecoder().decode([ChatSessionBackup].self, from: data)
        return backups.map { $0.toSession() }
    } catch {
        print("Error reading or decoding file: \(error)")
        throw error
    }
}
