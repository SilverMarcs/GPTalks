//
//  ToolsController.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

struct ToolsController: View {
    @Binding var tools: SessionConfigTools
    
    var body: some View {
        Section("Tools") {
            ForEach(ChatTool.allCases, id: \.self) { tool in
                Toggle(tool.displayName, isOn: Binding(
                    get: { tools.isToolEnabled(tool) },
                    set: { tools.setTool(tool, enabled: $0) }
                ))
            }
        }
    }
}