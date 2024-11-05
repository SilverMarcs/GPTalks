//
//  ToolResponse.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import Foundation

struct ToolResponse: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var toolCallId: String
    var tool: ChatTool
    var processedContent: String = ""
    var processedData: [Data] = []
}
