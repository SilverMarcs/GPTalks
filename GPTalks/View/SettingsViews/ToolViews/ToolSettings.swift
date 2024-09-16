//
//  ToolSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import SwiftUI

struct ToolSettings: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    
    var body: some View {
        NavigationStack {
            Form {
                //            Toggle("Google Search", isOn: $config.googleSearch)
                //            Toggle("URL Scrape", isOn: $config.urlScrape)
                //            Toggle("Image Generate", isOn: $config.imageGenerate)
                //            Toggle("Transcribe", isOn: $config.transcribe)
                
                ForEach(ChatTool.allCases, id: \.self) { tool in
                    NavigationLink(value: tool) {
                        Label(tool.displayName, systemImage: tool.icon)
                    }
                }
            }
            .navigationDestination(for: ChatTool.self) { tool in
                Form {
                    tool.settings
                }
                .navigationTitle("\(tool.displayName) Settings")
                .formStyle(.grouped)
                .scrollContentBackground(.visible)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Tool Settings")
    }
}

#Preview {
    ToolSettings()
}
