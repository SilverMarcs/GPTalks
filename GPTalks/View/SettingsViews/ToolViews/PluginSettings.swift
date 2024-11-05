//
//  PluginSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import SwiftUI

struct PluginSettings: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    var providerDefaults: ProviderDefaults
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Gemini Plugins") {
                    NavigationLink {
                        Form {
                            Toggle(isOn: $config.googleCodeExecution) {
                                Text("Enabled for new chats")
                                Text("Only available for Google AI Provider")
                            }
                        }
                        .navigationTitle("Google Code Execution")
                        .formStyle(.grouped)
                        .scrollContentBackground(.visible)
                    } label: {
                        Label("Code Execution", systemImage: "curlybraces")
                    }
                    
                    NavigationLink {
                        Form {
                            Toggle(isOn: $config.googleSearchRetrieval) {
                                Text("Enabled for new chats")
                                Text("Only available for Google AI Provider")
                            }
                        }
                        .navigationTitle("Search Retrieval")
                        .formStyle(.grouped)
                        .scrollContentBackground(.visible)
                    } label: {
                        Label {
                            Text("Search Retrieval")
                        } icon: {
                            Image("google.SFSymbol")
                        }
                    }
                }
                
                Section("General Plugins") {
                    ForEach(ChatTool.allCases, id: \.self) { tool in
                        NavigationLink(value: tool) {
                            Label(tool.displayName, systemImage: tool.icon)
                        }
                    }
                }
            }
            .navigationDestination(for: ChatTool.self) { tool in
                Form {
                    tool.settings(providerDefaults: providerDefaults)
                }
                .navigationTitle("\(tool.displayName) Settings")
                .toolbarTitleDisplayMode(.inline)
                .formStyle(.grouped)
                .scrollContentBackground(.visible)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Plugins")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    PluginSettings(providerDefaults: .mockProviderDefaults)
}
