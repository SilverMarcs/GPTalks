//
//  ChatTool.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/09/2024.
//

import SwiftUI
import SwiftOpenAI
import GoogleGenerativeAI
import SwiftData

enum ChatTool: String, CaseIterable, Codable, Identifiable {
    var id: Self {
        return self
    }
    
    case urlScrape = "urlScrape"
    case googleSearch = "googleSearch"
    case imageGenerate = "imageGenerate"
    case transcribe = "transcribe"
    case pdfReader = "pdfReader"
    
    var openai: ChatCompletionParameters.Tool {
        switch self {
        case .urlScrape:
            URLScrape.openai
        case .googleSearch:
            GoogleSearch.openai
        case .imageGenerate:
            GenerateImage.openai
        case .transcribe:
            URLScrape.openai
        case .pdfReader:
            PDFReader.openai
        }
    }
    
    var google: Tool {
        switch self {
        case .urlScrape:
            URLScrape.google
        case .googleSearch:
            GoogleSearch.google
        case .imageGenerate:
            GenerateImage.google
        case .transcribe:
            URLScrape.google
        case .pdfReader:
            PDFReader.google
        }
    }
    
    var vertex: [String: Any] {
        switch self {
        case .urlScrape:
            URLScrape.vertex
        case .googleSearch:
            GoogleSearch.vertex
        case .imageGenerate:
            GenerateImage.vertex
        case .transcribe:
            URLScrape.vertex
        case .pdfReader:
            PDFReader.vertex
        }
    }
    
    var tokenCount: Int {
        switch self {
        case .urlScrape:
            URLScrape.tokenCount
        case .googleSearch:
            GoogleSearch.tokenCount
        case .imageGenerate:
            GenerateImage.tokenCount
        case .transcribe:
            0
        case .pdfReader:
            PDFReader.tokenCount
        }
    }
    
    func process(arguments: String) async throws -> ToolData {
        switch self {
        case .urlScrape:
            try await URLScrape.getContent(from: arguments)
        case .googleSearch:
            try await GoogleSearch.getResults(from: arguments)
        case .imageGenerate:
            try await GenerateImage.generateImage(from: arguments)
        case .transcribe:
                .init(string: "No tool available")
        case .pdfReader:
            try await PDFReader.getContent(from: arguments)
        }
    }
    
    @ViewBuilder
    var settings: some View {
        switch self {
        case .urlScrape:
            URLScrapeSettings()
        case .googleSearch:
            GoogleSearchSettings()
        case .imageGenerate:
            GenerateImageSettings()
        case .transcribe:
            TranscribeSettings()
        case .pdfReader:
            PDFReaderSettings()
        }
    }
    
    var displayName: String {
        switch self {
        case .urlScrape:
            "URL Scrape"
        case .googleSearch:
            "Google Search"
        case .imageGenerate:
            "Image Generate"
        case .transcribe:
            "Transcribe"
        case .pdfReader:
            "PDF Reader"
        }
    }
    
    var icon: String {
        switch self {
        case .urlScrape:
            "network"
        case .googleSearch:
            "safari"
        case .transcribe:
            "waveform"
        case .imageGenerate:
            "photo"
        case .pdfReader:
            "doc.text"
        }
    }
}
