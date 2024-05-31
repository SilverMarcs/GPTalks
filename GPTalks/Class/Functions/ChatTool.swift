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
    case extractPdf = "extractPdf"
    case vision = "vision"

    static func enabledTools(for configuration: DialogueSession.Configuration) -> [ChatQuery.ChatCompletionToolParam] {
        return ChatTool.allCases.filter { tool in
            switch tool {
            case .googleSearch:
                return configuration.useGSearch
            case .urlScrape:
                return configuration.useUrlScrape
            case .imageGenerate:
                return configuration.useImageGenerate
            case .transcribe:
                return configuration.useTranscribe
            case .extractPdf:
                return configuration.useExtractPdf
            case .vision:
                return configuration.useVision
            }
        }.map { $0.completionToolParam }
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
        case .extractPdf:
            return .init(function:
                    .init(name: "extractPdf",
                          description: "If the user's input message contains something like a path to a PDF file, then call this function with the exact filepath that the user provided. Do not add or format the file url in any way. For example, if the user's provided file path was 'file:///Users/Zabir/Downloads/sample_pdf.pdf' then you need to return exactly 'file:///Users/Zabir/Downloads/sample_pdf.pdf'. The Tool will provide you with text extracted from the PDF file. You can use this text to answer the user's question.",
                          parameters:
                            .init(type: .object,
                                  properties: [self.paramName:
                                        .init(type: .string,
                                              description: "The file path for the user's PDF file")]
                                 )
                         )
            )
        case .vision:
            return .init(function:
                    .init(name: "vision",
                          description: """
                          If the user's input message contains something like a path to an image file, then call this function with the exact filepaths that the user provided. Do not add or format the file url in any way. For example, if the user's provided file path was 'file:///Users/Zabir/Downloads/test.jpg' then you need to return exactly 'file:///Users/Zabir/Downloads/test.jpg'. Multiple imagePaths may be provided joined by '|||'.
                          The vision tool, GPT-4 vision is able to find information from images based on the prompt you give to it. Keep the prompt as close as possible to the user's initial request. But be very careful about the number of times you call this function as it is a very expensive operation. Unless absolutely necessary, avoid multiple calls of the tool for the same image.
                          """,
                          parameters:
                            .init(type: .object,
                                  properties: [
                                    "imagePaths":
                                            .init(type: .array, description: "The array of file paths for the user's image file", items: .init(type: .string)),
                                    "prompt":
                                        .init(type: .string,
                                              description: "Prompt for the vision tool to describe the image")
                                    ]
                                 )
                         )
            )
        }
    }
    
    static func countTokensForEnabledCases(configuration: DialogueSession.Configuration) -> Int {
        var totalTokenCount = 0
        for tool in ChatTool.allCases {
            switch tool {
            case .googleSearch where configuration.useGSearch,
                 .urlScrape where configuration.useUrlScrape,
                 .imageGenerate where configuration.useImageGenerate,
                 .transcribe where configuration.useTranscribe,
                 .extractPdf where configuration.useExtractPdf,
                 .vision where configuration.useVision:
                let description = tool.completionToolParam.function.description
                let tokenCountForDescription = tokenCount(text: description ?? "")
                totalTokenCount += tokenCountForDescription
            default:
                continue
            }
        }
        return totalTokenCount
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
        case .extractPdf:
            PDFExtractConfigurationView()
        case .vision:
            VisionConfigurationView()
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
        case .extractPdf:
            "pdfPath"
        case .vision:
            "imagePath"
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
        case .extractPdf:
            "Extract PDF"
        case .vision:
            "Vision"
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
        case .extractPdf:
            return "doc.richtext"
        case .vision:
            return "eye"
        }
    }
}

struct URLScrapeConfigurationView: View {
    @ObservedObject var appConfig = AppConfiguration.shared
    
    var body: some View {
        Form {
            Section("Ask the assistant to scrape a webpage for information.") {
                Toggle("Enable URL Scrape", isOn: $appConfig.isUrlScrapeEnabled)
                
                Toggle("Experimental Scraper (Beta)", isOn: appConfig.$useExperimentalWebScraper)
            }
        }
        .navigationTitle("URL Scrape")
    }
}

struct GoogleSearchConfigurationView: View {
    @ObservedObject var appConfig = AppConfiguration.shared
    
    var body: some View {
        Section("Ask the assistant to make a google search and retrieve the user's content.") {
            Form {
                Toggle("Enable Google Search", isOn: $appConfig.isGoogleSearchEnabled)
                
                TextField("API Key", text: appConfig.$googleApiKey)
                
                TextField("Engine ID", text: appConfig.$googleSearchEngineId)
            }
            #if os(macOS)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
            #endif
        }
    }
}

struct ImageGenerateConfigurationView: View {
    @ObservedObject var appConfig = AppConfiguration.shared
    
    var body: some View {
        Form {
            Section("Ask the assistant to generate an image with a description of the image.") {
                Toggle("Enable Image Generate", isOn: $appConfig.isImageGenerateEnabled)
                
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
                Toggle("Enable Transcribe", isOn: $appConfig.isTranscribeEnabled)
                
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
                
                Toggle("Alternate Player", isOn: appConfig.$alternateAudioPlayer)
                    .toggleStyle(.switch)
                
            }
        }
        .navigationTitle("Transcribe")
    #if os(macOS)
        .frame(maxWidth: 400)
    #endif
    }
}

struct PDFExtractConfigurationView: View {
    @ObservedObject var appConfig = AppConfiguration.shared
    
    var body: some View {
        Form {
            Section("Upload a PDF file and ask the assistant to extract the text from it.") {
                Toggle("Enable Extract PDF", isOn: $appConfig.isExtractPdfEnabled)
            }
        }
        .navigationTitle("Extract PDF")
    #if os(macOS)
        .frame(maxWidth: 400)
    #endif
    }
}

struct VisionConfigurationView: View {
    @ObservedObject var appConfig = AppConfiguration.shared
    
    var body: some View {
        Form {
            Section("Ask the assistant to recognize the content of an image.") {
                Toggle("Enable Vision", isOn: $appConfig.isVisionEnabled)
                
                Picker("Visiom Provider", selection: appConfig.$visionProvider) {
                    ForEach(Provider.allCases, id: \.self) { provider in
                        Text(provider.name)
                            .tag(provider.rawValue)
                    }
                }
            }
        }
    #if os(macOS)
        .frame(maxWidth: 400)
    #else
        .navigationBarTitle("Vision")
    #endif
    }
}

struct ToolToggle: View {
    @Bindable var session: DialogueSession
    
    var body: some View {
        Menu {
            Toggle("GSearch", isOn: $session.configuration.useGSearch)
            Toggle("URL Scrape", isOn: $session.configuration.useUrlScrape)
            Toggle("Image Generate", isOn: $session.configuration.useImageGenerate)
            Toggle("Transcribe", isOn: $session.configuration.useTranscribe)
            Toggle("Extract PDF", isOn: $session.configuration.useExtractPdf)
            Toggle("Vision", isOn: $session.configuration.useVision)
        } label: {
//            Text("Use Tools")
            Label("Use Tools", systemImage: "hammer")
        }
    }
}
