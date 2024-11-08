//
//  ToolProtocol.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/10/2024.
//

import Foundation
import OpenAI
import GoogleGenerativeAI

protocol ToolProtocol {
    static var openai: ChatQuery.ChatCompletionToolParam { get }
    static var google: Tool { get }
    static var vertex: [String: Any] { get }
    static var jsonSchemaString: String { get }
    static var toolName: String { get }
    static var displayName: String { get }
    static var icon: String { get }
    static func process(arguments: String) async throws -> ToolData
}
