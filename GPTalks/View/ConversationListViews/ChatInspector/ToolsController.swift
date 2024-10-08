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
        ForEach(ChatTool.allCases, id: \.self) { tool in
            Toggle(
                tool.displayName,
                systemImage: tool.icon,
                isOn: Binding(
                    get: { tools.isToolEnabled(tool) },
                    set: { tools.setTool(tool, enabled: $0) }
                )
            )
        }
    }
}
