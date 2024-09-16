//
//  SessionConfigTools.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import Foundation

struct SessionConfigTools: Codable {
    private var toolStates: [ChatTool: Bool]
    
    init() {
        // Initialize with default values from SessionConfigDefaults
        toolStates = [
            .googleSearch: ToolConfigDefaults.shared.googleSearch,
            .urlScrape: ToolConfigDefaults.shared.urlScrape,
            .imageGenerate: ToolConfigDefaults.shared.imageGenerate,
            .transcribe: ToolConfigDefaults.shared.transcribe
        ]
    }

    var enabledTools: [ChatTool] {
        return toolStates.filter { $0.value }.map { $0.key }
    }
    
    // You can also provide methods to enable/disable specific tools
    mutating func setTool(_ tool: ChatTool, enabled: Bool) {
        toolStates[tool] = enabled
    }
    
    func isToolEnabled(_ tool: ChatTool) -> Bool {
        return toolStates[tool] ?? false
    }
}

