//
//  ToolSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import SwiftUI

struct ToolSettings: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    var providerDefaults: ProviderDefaults
    
    var body: some View {
        NavigationStack {
            Form {
                NavigationLink {
                    Form {
                        Toggle(isOn: $config.googleCodeExecution) {
                            Text("Enabled for new chats")
                            Text("Only available for Google Generative AI Provider")
                        }
                    }
                    .navigationTitle("Code Execution")
                    .formStyle(.grouped)
                    .scrollContentBackground(.visible)
                } label: {
                    Label("Code Execution", systemImage: "curlybraces")
                }
                
                NavigationLink {
                    Form {
                        Toggle(isOn: $config.googleSearchRetrieval) {
                            Text("Enabled for new chats")
                            Text("Only available for Google Generative AI Provider")
                        }
                    }
                    .navigationTitle("Google Search Retrieval")
                    .formStyle(.grouped)
                    .scrollContentBackground(.visible)
                } label: {
                    Label {
                        Text("Google Search Retrieval")
                    } icon: {
                        Image("google.SFSymbol")
                    }
                }
                
                ForEach(ChatTool.allCases, id: \.self) { tool in
                    NavigationLink(value: tool) {
                        Label(tool.displayName, systemImage: tool.icon)
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
    ToolSettings(providerDefaults: .mockProviderDefaults)
}
