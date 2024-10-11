//
//  ChatSessionExporting.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - JSON Exporting
struct SessionFileExporterModifier: ViewModifier {
    @Binding var isExporting: Bool
    let sessions: [ChatSession]
    
    func body(content: Content) -> some View {
        content
            .fileExporter(
                isPresented: $isExporting,
                document: SessionsDocument(sessions: sessions),
                contentType: .json,
                defaultFilename: "sessions_backup"
            ) { result in
                switch result {
                case .success(let url):
                    print("Sessions backup saved to: \(url.path)")
                case .failure(let error):
                    print("Error saving sessions backup: \(error.localizedDescription)")
                }
            }
    }
}

struct SessionFileImporterModifier: ViewModifier {
    @Binding var isImporting: Bool
    let modelContext: ModelContext
    let existingSessions: [ChatSession]
    
    func body(content: Content) -> some View {
        content
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    do {
                        let restoredSessions = try restoreSessions(from: url)
                        for session in restoredSessions {
                            if !existingSessions.contains(where: { $0.id == session.id }) {
                                modelContext.insert(session)
                            }
                        }
                    } catch {
                        print("Error restoring sessions backup: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("Error selecting file: \(error.localizedDescription)")
                }
            }
    }
}

extension View {
    func sessionExporter(isExporting: Binding<Bool>, sessions: [ChatSession]) -> some View {
        self.modifier(SessionFileExporterModifier(isExporting: isExporting, sessions: sessions))
    }
    
    func sessionImporter(isImporting: Binding<Bool>, modelContext: ModelContext, existingSessions: [ChatSession]) -> some View {
        self.modifier(SessionFileImporterModifier(isImporting: isImporting, modelContext: modelContext, existingSessions: existingSessions))
    }
}

// MARK: - Markdown Exporting

struct MarkdownFile: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }

    var text: String

    init(initialText: String = "") {
        text = initialText
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        } else {
            text = ""
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}

private func generateMarkdown(for session: ChatSession) -> String {
    var markdown = "# Session: \(session.title)\n\n"
    
    for group in session.groups {
        let activeConversation = group.activeConversation
        markdown += "## \(activeConversation.role.rawValue.capitalized)\n"
        markdown += "\(activeConversation.content)\n\n\n"
    }
        
    return markdown
}
    
private func exportMarkdown(session: ChatSession) {
    let markdown = generateMarkdown(for: session)
    
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(session.title).md")
    do {
        try markdown.write(to: tempURL, atomically: true, encoding: .utf8)
    } catch {
        print("Failed to write markdown: \(error)")
    }
}

extension View {
    func markdownSessionExporter(isExporting: Binding<Bool>, session: ChatSession) -> some View {
        let markdown = generateMarkdown(for: session)
        return self.fileExporter(
            isPresented: isExporting,
            document: MarkdownFile(initialText: markdown),
            contentType: .plainText,
            defaultFilename: "\(session.title).md"
        ) { result in
            switch result {
            case .success(let url):
                print("Markdown saved to \(url)")
            case .failure(let error):
                print("Error saving markdown: \(error)")
            }
        }
    }
}
