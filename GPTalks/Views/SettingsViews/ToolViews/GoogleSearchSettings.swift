//
//  GoogleSearchSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

struct GoogleSearchSettings: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    
    var body: some View {
        Section("General") {
            Toggle(isOn: $config.googleSearch) {
                Text("Enabled for new chats")
            }
        }
        
        Section {
            SecretInputView(label: "Google Search Engine ID", secret: $config.googleSearchEngineId)
            SecretInputView(label: "Google Search API Key", secret: $config.googleApiKey)
        } header: {
            Text("Secrets")
        } footer: {
            SectionFooterView(text: "Follow [this](https://coda.io/@jon-dallas/google-image-search-pack-example/search-engine-id-and-google-api-key-3) guide to get your credentials")
        }
        
        Section("Schema") {
            MarkdownView(content: ChatTool.googleSearch.jsonSchemaString)
                .padding(.bottom, -11)
        }
    }
}

#Preview {
    GoogleSearchSettings()
}
