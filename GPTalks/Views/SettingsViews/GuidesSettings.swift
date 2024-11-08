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
                ForEach(Shortcut.shortcuts, id: \.key) { shortcut in
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
            
            ForEach(Guide.guides) { guide in
                Section {   
                    DisclosureGroup {
                        MarkdownView(content: guide.content)
                    } label: {
                        Text(guide.title)
                            .font(.title3.bold())
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Guides")
    }
}

struct GuideSection: View {
    let guide: Guide
    
    var body: some View {
//        Section(guide.title) {
//            
//            Text(LocalizedStringKey(guide.content))
//                .multilineTextAlignment(.leading)
//                .textSelection(.enabled)
//            MarkdownView(content: guide.content)
//        }
        
        DisclosureGroup {
            MarkdownView(content: guide.content)
        } label: {
            Text(guide.title)
                .font(.title3.bold())
        }
    }
}

#Preview {
    GuidesSettings()
        .frame(width: 450)
}
