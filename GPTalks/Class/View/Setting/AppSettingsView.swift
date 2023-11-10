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
                Section {
                    HStack {
                        Image(systemName: "key.fill")
                        Spacer()
                        if showAPIKey {
                            TextField("OpenAI API Key", text: $configuration.rapidApiKey)
                                .truncationMode(.middle)
                        } else {
                            SecureField("OpenAI API Key", text: $configuration.rapidApiKey)
                                .truncationMode(.middle)
                        }
                        Button {
                            showAPIKey.toggle()
                        } label: {
                            if showAPIKey {
                                Image(systemName: "eye.slash")
                            } else {
                                Image(systemName: "eye")
                            }
                        }
                    }
                }
            }
            Section("Services") {
                NavigationLink {
                    OpenAISettingsView()
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
                    OpenRouterSettingsView()
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
                    SummarySettingsView()
                } label: {
                    HStack {
                        Image("summaries")
                            .resizable()
                            .cornerRadius(10)
                            .frame(width: 30, height: 30)
                        Text("Summaries")
                    }
                }
            }
//            Section("Model") {
//                NavigationLink {
//                    OpenRouterSettingsView()
//                } label: {
//                    HStack {
//                        Image("openai")
//                            .resizable()
//                            .cornerRadius(10)
//                            .frame(width: 30, height: 30)
//                        Text("OpenRouter")
//                    }
//                }
//            }
            Section("Prompt") {
                NavigationLink {
                    PromptsListView()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Sync Prompts")
                    }
                }
                NavigationLink {
                    CustomPromptsView()
                } label: {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Custom Prompts")
                    }
                }
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
