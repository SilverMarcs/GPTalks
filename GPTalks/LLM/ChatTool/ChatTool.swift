//
//  ChatTool.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import SwiftUI
import OpenAI
import GoogleGenerativeAI
import SwiftData

enum ChatTool: String, CaseIterable, Codable, Identifiable {
    var id: Self {
        return self
    }
    
    case urlScrape = "urlScrape"
    case googleSearch = "googleSearch"
    case imageGenerator = "imageGenerator"
    case transcribe = "transcribe"
    case pdfReader = "pdfReader"
    
    var toolType: ToolProtocol.Type {
        switch self {
        case .urlScrape: return URLScrape.self
        case .googleSearch: return GoogleSearch.self
        case .imageGenerator: return ImageGenerator.self
        case .transcribe: return TranscribeTool.self
        case .pdfReader: return PDFReader.self
        }
    }
    
    var openai: ChatQuery.ChatCompletionToolParam {
        toolType.openai
    }
    
    var google: Tool {
        toolType.google
    }
    
    var vertex: [String: Any] {
        toolType.vertex
    }
    
    var tokenCount: Int {
        toolType.tokenCount
    }
    
    func process(arguments: String) async throws -> ToolData {
        try await toolType.process(arguments: arguments)
    }
    
    var displayName: String {
        toolType.displayName
    }
    
    var icon: String {
        toolType.icon
    }
    
    @ViewBuilder
    func settings(providerDefaults: ProviderDefaults) -> some View {
        switch self {
        case .urlScrape:
            URLScrapeSettings()
        case .googleSearch:
            GoogleSearchSettings()
        case .imageGenerator:
            GenerateImageSettings(providerDefaults: providerDefaults)
        case .transcribe:
            TranscribeSettings(providerDefaults: providerDefaults)
        case .pdfReader:
            PDFReaderSettings()
        }
    }
}
