//
//  GuidesSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/11/2024.
//

import SwiftUI

struct GuidesSettings: View {
    var body: some View {
        Form {
            #if os(macOS)
            Section(header: Text("Keyboard Shortcuts").font(.headline)) {
                ForEach(shortcuts, id: \.key) { shortcut in
                    HStack {
                        Text(shortcut.key)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(shortcut.action)
                    }
                }
            }
            #endif
            
            ForEach(guides) { guide in
                GuideSection(guide: guide)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Guides")
    }
    
    private let shortcuts = [
        Shortcut(key: "⌘ + N", action: "New Chat"),
        Shortcut(key: "⌘ + Enter", action: "Send Prompt"),
        Shortcut(key: "⌘ + R", action: "Regenerate Last Response"),
        Shortcut(key: "⌘ + E", action: "Edit Last Prompt"),
        Shortcut(key: "⌘ + D", action: "Delete Last Prompt/Response"),
        Shortcut(key: "⌘ + .", action: "Open Chat Config Menu"),
        Shortcut(key: "⌘ + ,", action: "Open App Settings"),
        Shortcut(key: "⌥ + Space", action: "Toggle Quick Panel"),
    ]
    
    private let guides = [
        Guide(title: "Incomplete View", content: "GThis section will be filled in progressively and mostly serves as placeholder for now"),
        Guide(title: "Google Plugin Settings", content: "Guide for configuring Google plugin settings..."),
        Guide(title: "URL Scrape Settings", content: "Instructions for setting up URL scraping..."),
        Guide(title: "Google Gemini Specific Plugins", content: "Information about Gemini-specific plugins..."),
        Guide(title: "General Plugins", content: "Overview of general plugins and their usage..."),
        Guide(title: "Adding New Providers", content: "Steps to add new AI providers to the app..."),
        Guide(title: "Adding Files", content: "Can read most text based files. audio file can be read by transcription tool..."),
        Guide(title: "Quick Panel Guide", content: "How to use and customize the Quick Panel feature...")
    ]
}

struct Shortcut {
    let key: String
    let action: String
}

struct Guide: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

struct GuideSection: View {
    let guide: Guide
    
    var body: some View {
        Section(guide.title) {
            Text(guide.content)
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    GuidesSettings()
        .frame(width: 450)
}
