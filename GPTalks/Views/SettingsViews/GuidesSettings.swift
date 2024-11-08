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
                GuideSection(guide: guide)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Guides")
    }
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
