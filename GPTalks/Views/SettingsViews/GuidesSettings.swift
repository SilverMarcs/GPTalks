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
                            .monospaced()
//                            .bold()
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
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    GuidesSettings()
        .frame(width: 450)
}
