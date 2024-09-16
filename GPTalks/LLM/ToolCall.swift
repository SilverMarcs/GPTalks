//
//  ToolCall.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import Foundation

struct ToolCall: Identifiable, Codable {
    var id: UUID = UUID()
    var toolCallId: String
    var tool: ChatTool
    var arguments: String
}

struct ToolResponse: Identifiable, Codable {
    var id: UUID = UUID()
    var toolCallId: String
    var tool: ChatTool
//    var toolData: ToolData
    var processedContent: String
    var processedData: [Data] = []
}
