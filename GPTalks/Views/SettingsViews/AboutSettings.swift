//
//  AboutSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/11/2024.
//

import SwiftUI

struct AboutSettings: View {
    var body: some View {
        Form {
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Image("AppIconPng")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Spacer()
                }
                    
                Text("GPTalks")
                    .font(.title.bold())
                
                Text("Multi-LLM API client written in SwiftUI")
                    .font(.subheadline)
                
                Text(getAppVersion())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("Made by SilverMarcs")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.bottom, 5)
            }
            
            Section("Connect") {
                Link(destination: URL(string: "https://github.com/SilverMarcs/GPTalks")!) {
                    HStack {
                        Image(systemName: "link")
                        Text("GitHub Repository")
                    }
                }
                Link(destination: URL(string: "https://twitter.com/SilverMarcs3")!) {
                    HStack {
                        Image(systemName: "person")
                        Text("Follow me on Twitter")
                    }
                }
            }
            
            Section("Acknowledgements") {
                AcknowledgementRow(name: "MacPaw/OpenAI", description: "Swift community driven package for OpenAI public API", url: "https://github.com/MacPaw/OpenAI")
                
                AcknowledgementRow(name: "SwiftAnthropic", description: "An open-source Swift package for interacting with Anthropic's public API.", url: "https://github.com/jamesrochabrun/SwiftAnthropic")

                AcknowledgementRow(name: "GoogleGenerativeAI", description: "The official Swift library for the Google Gemini API", url: "https://github.com/google-gemini/generative-ai-swift")
                
                AcknowledgementRow(name: "markdown-webview", description: "A performant SwiftUI Markdown view", url: "https://github.com/tomdai/markdown-webview")

                AcknowledgementRow(name: "KeyboardShortcuts", description: "Add user-customizable global keyboard shortcuts (hotkeys) to your macOS app in minutes", url: "https://github.com/sindresorhus/KeyboardShortcuts")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("About")
    }
    
    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
           {
            return "Version \(version)"
        }
        return "Version Unknown"
    }

}

struct AcknowledgementRow: View {
    let name: String
    let description: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            VStack(alignment: .leading, spacing: 5) {
                Text(name)
                    .font(.headline)
                Text(description)
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    AboutSettings()
        .frame(width: 500)
}
