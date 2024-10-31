//
//  SessionConfigTools.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import Foundation

struct SessionConfigTools: Codable {
    var toolStates: [ChatTool: Bool]
    var googleCodeExecution: Bool = ToolConfigDefaults.shared.googleCodeExecution
    
    init(isTitle: Bool = false) {
        if isTitle {
            toolStates = [
                .googleSearch: false,
                .urlScrape: false,
                .imageGenerator: false,
                .transcribe: false,
                .pdfReader: false
            ]
        } else {
            toolStates = [
                .googleSearch: ToolConfigDefaults.shared.googleSearch,
                .urlScrape: ToolConfigDefaults.shared.urlScrape,
                .imageGenerator: ToolConfigDefaults.shared.imageGenerate,
                .transcribe: ToolConfigDefaults.shared.transcribe,
                .pdfReader: ToolConfigDefaults.shared.pdfReader
            ]
        }
    }

    var enabledTools: [ChatTool] {
        return toolStates.filter { $0.value }.map { $0.key }
    }
    
    var tokenCount: Int {
        return enabledTools.reduce(0) { $0 + $1.tokenCount }
    }
    
    mutating func setGoogleCodeExecution(_ enabled: Bool) {
        googleCodeExecution = enabled
        if enabled {
            disableAllTools()
        }
    }

    mutating func setTool(_ tool: ChatTool, enabled: Bool) {
        toolStates[tool] = enabled
        if enabled {
            googleCodeExecution = false
        }
    }

    mutating func disableAllTools() {
        toolStates = toolStates.mapValues { _ in false }
    }

    func isToolEnabled(_ tool: ChatTool) -> Bool {
        return toolStates[tool] ?? false
    }
}

