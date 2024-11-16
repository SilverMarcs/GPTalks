//
//  GuidesSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/11/2024.
//

import SwiftUI
import SwiftMarkdownView

struct GuidesSettings: View {
    @State private var isExpanded = true
    @State private var searchText = ""

    var filteredGuides: [Guide] {
        if searchText.isEmpty {
            return Guide.guides
        } else {
            return Guide.guides.filter { guide in
                guide.title.localizedCaseInsensitiveContains(searchText) ||
                guide.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        Form {
            #if os(macOS)
            Section("Keyboard Shortcuts", isExpanded: $isExpanded) {
                ForEach(Shortcut.shortcuts, id: \.key) { shortcut in
                    HStack {
                        Text(shortcut.key)
                            .monospaced()
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(shortcut.action)
                    }
                }
            }
            #endif
            
            ForEach(filteredGuides) { guide in
                Section {
                    DisclosureGroup {
                        SwiftMarkdownView(guide.content)
                            .markdownBaseURL("GPTalks Guide")
                            .markdownHighlightString(searchText)
                            .renderSkeleton(false)
                        
                    } label: {
                        HStack {
                            Text(guide.title)
                                .font(.title3.bold())
                            
                            Spacer()
                            
                            Image(systemName: guide.icon)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search Guides")
        .onChange(of: searchText) {
            isExpanded = searchText.isEmpty
        }
        .formStyle(.grouped)
        .navigationTitle("Guides")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    GuidesSettings()
        .frame(width: 450)
}
