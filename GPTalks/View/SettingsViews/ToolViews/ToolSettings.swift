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
                .toolbarTitleDisplayMode(.inline)
                .formStyle(.grouped)
                .scrollContentBackground(.visible)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Tool Settings")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    ToolSettings()
}
