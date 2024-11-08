//
//  ChatConfigTools.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import Foundation

struct ChatConfigTools: Codable {
    var toolStates: [ChatTool: Bool]
    var googleCodeExecution: Bool = ToolConfigDefaults.shared.googleCodeExecution
    var googleSearchRetrieval: Bool = ToolConfigDefaults.shared.googleSearchRetrieval
    
    init(isTitle: Bool = false) {
        if isTitle {
            toolStates = [
                .googleSearch: false,
                .urlScrape: false,
                .imageGenerator: false,
                .transcribe: false
            ]
        } else {
            toolStates = [
                .googleSearch: ToolConfigDefaults.shared.googleSearch,
                .urlScrape: ToolConfigDefaults.shared.urlScrape,
                .imageGenerator: ToolConfigDefaults.shared.imageGenerate,
                .transcribe: ToolConfigDefaults.shared.transcribe
            ]
        }
    }

    var enabledTools: [ChatTool] {
        return toolStates.filter { $0.value }.map { $0.key }
    }
    
    mutating func setGoogleCodeExecution(_ enabled: Bool) {
        googleCodeExecution = enabled
        if enabled {
            disableAllTools()
            googleSearchRetrieval = false
        }
    }
    
    mutating func setGoogleSearchRetrieval(_ enabled: Bool) {
        googleSearchRetrieval = enabled
        if enabled {
            disableAllTools()
            googleCodeExecution = false
        }
    }

    mutating func setTool(_ tool: ChatTool, enabled: Bool) {
        toolStates[tool] = enabled
        if enabled {
            googleCodeExecution = false
            googleSearchRetrieval = false
        }
    }

    mutating func disableAllTools() {
        toolStates = toolStates.mapValues { _ in false }
    }

    func isToolEnabled(_ tool: ChatTool) -> Bool {
        return toolStates[tool] ?? false
    }
}

