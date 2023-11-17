//
//  SettingsView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/7.
//

import SwiftUI

struct AppSettingsView: View {
    
    @ObservedObject var configuration: AppConfiguration
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    @State var showAPIKey = false
    
    var body: some View {
        Form {
            Section("General") {
                HStack {
                    Image(systemName: "text.bubble.fill")
                        .renderingMode(.original)
                    Spacer()
                    Toggle("Markdown Enabled", isOn: $configuration.isMarkdownEnabled)
                }
                HStack {
                    Image(systemName: "building.2.fill")
                        .renderingMode(.original)
                    Text("Default Provider")
                        .lineLimit(1)
                    Spacer()
                    Picker("", selection: configuration.$preferredChatService) {
                        ForEach(AIProvider.allCases, id: \.self) { provider in
                            Text(provider.name)
                                .tag(provider.id)
                        }
                    }
                }
            }
            Section("Services") {
                NavigationLink {
                    ServiceSettingsView(
                        model: configuration.$OAImodel,
                        temperature: configuration.$OAItemperature,
                        contextLength: configuration.$OAIcontextLength,
                        systemPrompt: configuration.$OAIsystemPrompt,
                        apiKey: configuration.$OAIkey,
                        models: AIProvider.openai.models,
                        navigationTitle: "OpenAI"
                    )
                } label: {
                    HStack {
                        Image("openai")
                            .resizable()
                            .cornerRadius(10)
                            .frame(width: 30, height: 30)
                        Text("OpenAI")
                    }
                }
                NavigationLink {
                    ServiceSettingsView(
                        model: configuration.$ORmodel,
                        temperature: configuration.$ORtemperature,
                        contextLength: configuration.$ORcontextLength,
                        systemPrompt: configuration.$ORsystemPrompt,
                        apiKey: configuration.$Ckey,
                        models: AIProvider.openrouter.models,
                        navigationTitle: "OpenRouter"
                    )
                } label: {
                    HStack {
                        Image("openrouter")
                            .resizable()
                            .cornerRadius(10)
                            .frame(width: 30, height: 30)
                        Text("OpenRouter")
                    }
                }
                NavigationLink {
                    ServiceSettingsView(
                        model: configuration.$Cmodel,
                        temperature: configuration.$Ctemperature,
                        contextLength: configuration.$CcontextLength,
                        systemPrompt: configuration.$CsystemPrompt,
                        apiKey: configuration.$Ckey,
                        models: AIProvider.custom.models,
                        navigationTitle: "Custom"
                    )
                } label: {
                    HStack {
                        Image("custom")
                            .resizable()
                            .cornerRadius(10)
                            .frame(width: 30, height: 30)
                        Text("PAI")
                    }
                }
//                NavigationLink {
//                    SummarySettingsView()
//                } label: {
//                    HStack {
//                        Image("summaries")
//                            .resizable()
//                            .cornerRadius(10)
//                            .frame(width: 30, height: 30)
//                        Text("Summaries")
//                    }
//                }
            }
        }
        .navigationTitle("Settings")
    }
}


struct AppSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AppSettingsView(configuration: AppConfiguration())
        }
    }
}
