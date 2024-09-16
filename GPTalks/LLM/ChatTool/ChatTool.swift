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

enum ChatTool: String, CaseIterable, Codable {
    case urlScrape = "urlScrape"
    case googleSearch = "googleSearch"
    case imageGenerate = "imageGenerate"
    case transcribe = "transcribe"
    
    var openai: ChatQuery.ChatCompletionToolParam {
        switch self {
        case .urlScrape:
            URLScrape.openai
        case .googleSearch:
            GoogleSearch.openai
        case .imageGenerate:
            GenerateImage.openai
        default:
            URLScrape.openai
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
        default:
            URLScrape.google
        }
    }
    
    func process(arguments: String, modelContext: ModelContext? = nil) async throws -> ToolData {
        switch self {
        case .urlScrape:
            try await URLScrape.getContent(from: arguments)
        case .googleSearch:
            try await GoogleSearch.getResults(from: arguments)
        case .imageGenerate:
            try await GenerateImage.generateImage(from: arguments, modelContext: modelContext)
        default:
            .init(string: "No tool")
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
        }
    }

    var completionToolParam: ChatQuery.ChatCompletionToolParam {
        switch self {
        case .urlScrape:
            return .init(function:
                    .init(name: "urlScrape",
                          description: """
                                        You can open a URL directly if one is provided by the user. 
                                        If you need more context or info, you may also call this with URLs returned by the googleSearch function.
                                        Use this if the context from a previous googleSearch is not sufficient to answer the user's question and you need more info
                                        for a more in-depth response.
                                        """,
                          parameters:
                            .init(type: .object,
                                  properties: [
                                    "url_list":
                                        .init(type: .array, description: "The array of URLs of the websites to scrape", items: .init(type: .string), maxItems: 5)
                                    ]
                                 )
                         )
            )
        case .googleSearch:
            return .init(function:
                    .init(name: "googleSearch",
                          description: """
                                        Use this when
                                        - User is asking about current events or something that requires real-time information (weather, sports scores, etc.)
                                        - User is asking about some term you are totally unfamiliar with (it might be new)
                                        - Usually prioritize your pre-existing knowledge
                                        """,
                          parameters:
                            .init(type: .object,
                                  properties: [self.paramName:
                                        .init(type: .string,
                                              description: "The search query to search google with")]
                                 )
                         )
            )
        case .imageGenerate:
            return .init(function:
                    .init(name: "imageGenerate",
                          description: "If the user asks to generate an image with a description of the image, create a prompt that dalle, an AI image creator, can use to generate the image(s). You may modify the user's such that dalle can create a more aesthetic and visually pleasing image. You may also specify the number of images to generate based on users request. If the user did not specify number, generate one image only.",
                          parameters:
                            .init(type: .object,
                                  properties:
                                    ["prompt":
                                        .init(type: .string,
                                              description: "The prompt for dalle"),
                                     "n":
                                        .init(type: .string,
                                              description: "The number of images to generate")
                                    ]
                                 )
                         )
            )
        case .transcribe:
            return .init(function:
                    .init(name: "transcribe",
                          description: "If the user's input message contains something like a path to an audio file, then call this function with the exact filepath that the user provided. Do not add or format the fiel url in any way. For example, if the user's provided file path was 'file:///Users/Zabir/Downloads/test.mp3' then you need to return exactly 'file:///Users/Zabir/Downloads/test.mp3'",
                          parameters:
                            .init(type: .object,
                                  properties: [self.paramName:
                                        .init(type: .string,
                                              description: "The file path for the user's audio file")]
                                 )
                         )
            )
        }
    }
    
    var paramName: String {
        switch self {
        case .urlScrape:
            "url"
        case .googleSearch:
            "searchQuery"
        case .imageGenerate:
            "prompt"
        case .transcribe:
            "audioPath"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .urlScrape:
            return "network"
        case .transcribe:
            return "waveform"
        case .imageGenerate:
            return "photo"
        case .googleSearch:
            return "safari"
        }
    }
}
