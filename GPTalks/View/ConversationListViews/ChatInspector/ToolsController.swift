//
//  ToolsController.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

struct ToolsController: View {
    @Binding var tools: SessionConfigTools
    let isGoogle: Bool
    
    var body: some View {
        if isGoogle {
            Toggle(
                "Google Code Execution",
                systemImage: "curlybraces",
                isOn: Binding(
                    get: { tools.googleCodeExecution },
                    set: { newValue in
                        tools.setGoogleCodeExecution(newValue)
                    })
            )
            .popoverTip(GoogleCodeExecutionTip())

            Toggle(
                isOn: Binding(
                    get: { tools.googleSearchRetrieval },
                    set: { newValue in
                        tools.setGoogleSearchRetrieval(newValue)
                    })
            ) {
                Label {
                    Text("Google Search Retrieval")
                } icon: {
                    Image("google.SFSymbol")
                }
            }
        }
        
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
