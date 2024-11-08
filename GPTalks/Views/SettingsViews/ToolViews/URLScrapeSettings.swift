//
//  URLScrapeSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

struct URLScrapeSettings: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    
    var body: some View {
        Section("General") {
            Toggle("Enabled for new chats", isOn: $config.urlScrape)
        }
        
        Section("Article Extractor") {
            TextField(text: $config.rapidApiKey) {
                Text("Rapid API Key")
                Text("Subscribe and get your API key [Here](https://rapidapi.com/pwshub-pwshub-default/api/article-extractor2)")
                    
            }
        }
        
        Section("Schema") {
            MarkdownView(content: ChatTool.urlScrape.jsonSchemaString)
                .padding(.bottom, -11)
        }
    }
}

#Preview {
    URLScrapeSettings()
}
