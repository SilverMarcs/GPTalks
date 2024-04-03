//
//  ChatFunctions.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/03/2024.
//


import SwiftUI
import OpenAI

enum ChatTool: String, CaseIterable {
    case googleSearch = "googleSearch"
    case urlScrape = "urlScrape"
    case imageGenerate = "imageGenerate"
    case transcribe = "transcribe"
    
    static var allTools: [ChatQuery.ChatCompletionToolParam] {
        return ChatTool.allCases.map { $0.completionToolParam }
    }
    
    var completionToolParam: ChatQuery.ChatCompletionToolParam {
        switch self {
        case .urlScrape:
            return .init(function:
                    .init(name: "urlScrape",
                          description: "If a URL is explicitly given, this function must be used to receive the contents of that url webpage. If you already know the information, do not use the function to come up with a url. Always prioritize your pre-existing knowledge. Note that this function CANNOT search the web on its own. It can only look up a sepcific url. If you find a previous google search in the chat history, you may find some urls in the search results. You may use one and only one of those urls to call this function to retrieve required. Be sure to choose the most appropriate url to call in that case on your own. The function will visit that url and return the webcontent from it. NEVER pass in wikipedia links as the paramater.",
                          parameters:
                            .init(type: .object,
                                  properties: ["url":
                                        .init(type: .string,
                                              description: "The URL of the website to scrape")]
                                 )
                         )
            )
        case .googleSearch:
            return .init(function:
                    .init(name: "googleSearch",
                          description: "If your preexisting knowledge does not contain info of the user's question, you may use this function to make a google search and retrieve the user's content. if a url has been explicitly given already, use the urlScape function instead. Always prioritize your pre-existing knowledge. Only use this function if the requested info is beyond your knowledge cutoff date. In the case where a google search will help you find the user's question's answer, come up with a meaningful search query to search google with and call the function with it. You will be receiving some website links and a small snippet from that webpage. Usually, the snippets should suffice to answer the user's question.",
                          parameters:
                            .init(type: .object,
                                  properties: ["searchQuery":
                                        .init(type: .string,
                                              description: "The search query to search google with")]
                                 )
                         )
            )
        case .imageGenerate:
            return .init(function:
                    .init(name: "imageGenerate",
                          description: "If the user asks to generate an image with a description of the image, create a prompt that dalle, an AI image creator, can use to generate the image(s). You may modify the user's such that dalle can create a more aesthetic and visually pleasing image.",
                          parameters:
                            .init(type: .object,
                                  properties: ["prompt":
                                        .init(type: .string,
                                              description: "The prompt for dalle")]
                                 )
                         )
            )
        case .transcribe:
            return .init(function:
                    .init(name: "transcribe",
                          description: "If the user's input message contains something like a path to an audio file, then call this function with the exact filepath that the user provided. Do not add or format the fiel url in any way. For example, if the user's provided file path was 'file:///Users/Zabir/Downloads/test.mp3' then you need to return exactly 'file:///Users/Zabir/Downloads/test.mp3'",
                          parameters:
                            .init(type: .object,
                                  properties: ["audioPath":
                                        .init(type: .string,
                                              description: "The file path for the user's audio file")]
                                 )
                         )
            )
        }
    }
    
    @ViewBuilder
    var destination: some View {
        @ObservedObject var appConfig = AppConfiguration.shared
        
        switch self {
        case .urlScrape:
            URLScrapeConfigurationView()
        case .googleSearch:
            GoogleSearchConfigurationView()
        case .imageGenerate:
            ImageGenerateConfigurationView()
        case .transcribe:
            TranscriptionConfigurationView()
        }
    }

    var toolName: String {
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

struct URLScrapeConfigurationView: View {
    @ObservedObject var appConfig = AppConfiguration.shared
    
    var body: some View {
        Form {
            Section("Ask the assistant to scrape a webpage for information.") {
                Toggle("Experimental Scraper (Beta)", isOn: appConfig.$useExperimentalWebScraper)
            }
        }
        .navigationTitle("URL Scrape")
    }
}

struct GoogleSearchConfigurationView: View {
    @ObservedObject var appConfig = AppConfiguration.shared
    
    var body: some View {
        Form {
            Section("Ask the assistant to make a google search and retrieve the user's content.") {
                Group {
                    TextField("GSearch API Key", text: appConfig.$googleApiKey)
                    
                    TextField("GSearch Engine ID", text: appConfig.$googleSearchEngineId)
                }
                #if os(macOS)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                #endif
            }
        }
        .navigationTitle("Google Search")
    }
}

struct ImageGenerateConfigurationView: View {
    @ObservedObject var appConfig = AppConfiguration.shared
    
    var body: some View {
        Form {
            Section("Ask the assistant to generate an image with a description of the image.") {
                Picker("Image Provider", selection: appConfig.$imageProvider) {
                    ForEach(Provider.allCases, id: \.self) { provider in
                        Text(provider.name)
                            .tag(provider.rawValue)
                    }
                }
                
                Picker("Image Model", selection: appConfig.$imageModel) {
                    ForEach(appConfig.imageProvider.imageModels, id: \.self) { model in
                        Text(model.name)
                            .tag(model.rawValue)
                    }
                }
            }
        }
        .navigationTitle("Image Generate")
    #if os(macOS)
        .frame(maxWidth: 400)
    #endif
    }
}

struct TranscriptionConfigurationView: View {
    @ObservedObject var appConfig = AppConfiguration.shared
    
    var body: some View {
        Form {
            Section("Upload an audio file and ask the assistant to transcribe it for you.") {
                Picker("Transcription Provider", selection: appConfig.$transcriptionProvider) {
                    ForEach(Provider.allCases, id: \.self) { provider in
                        Text(provider.name)
                            .tag(provider.rawValue)
                    }
                }
                
                Picker("Transcription Model", selection: appConfig.$transcriptionModel) {
                    ForEach(appConfig.transcriptionProvider.transcriptionModels, id: \.self) { model in
                        Text(model.name)
                            .tag(model.rawValue)
                    }
                }
            }
        }
        .navigationTitle("Transcribe")
    #if os(macOS)
        .frame(maxWidth: 400)
    #endif
    }
}
