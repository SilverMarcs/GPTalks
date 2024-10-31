//
//  MarkdownSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/08/2024.
//

import SwiftUI
import MarkdownWebView

struct MarkdownSettings: View {
    @ObservedObject var config = AppConfig.shared
    
    var body: some View {
        Form {
            Picker("Markdown Provider", selection: $config.markdownProvider) {
                ForEach(MarkdownProvider.allCases, id: \.self) { provider in
                    Text(provider.name)
                }
            }
            
//            if config.markdownProvider != .native || config.markdownProvider != .disabled {
//                Picker("Codeblock Theme", selection: $config.markdownTheme) {
//                    ForEach(MarkdownTheme.allCases, id: \.self) { theme in
//                        Text(theme.name)
//                    }
//                }
//            }
            
            Section("Demo") {
                MarkdownView(conversation: Conversation.mockAssistantConversation)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Parameters")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    MarkdownSettings()
}
