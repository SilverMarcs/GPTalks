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
    
    static var allTools: [ChatQuery.ChatCompletionToolParam] {
        return ChatTool.allCases.map { $0.completionToolParam }
    }
    
    var completionToolParam: ChatQuery.ChatCompletionToolParam {
        switch self {
        case .urlScrape:
            return .init(function:
                    .init(name: "urlScrape",
                          description: "This function can be used to retrieve web content of any number of URLs. If you find a previous google search in the chat history, you may find some urls in the search results. You may initially use only one of those urls to call this function to retrieve required info. If a certain URL content had been retrieved earlier, but the user's information was not found from it, you may visit some more urls one by one. Be sure to choose the most appropriate url to call in that case on your own. The function will visit that url and return the webcontent from it. NEVER pass in wikipedia links as the paramater. Only if the user explcitly provides multiple urls, you will visit them all in one go. If after attempting to retrieve a URL's content, content was not properly received, keep accessing urls from previous search results, one at a time.",
                          parameters:
                            .init(type: .object,
                                  properties: [
                                    "url_list":
                                        .init(type: .array, description: "The array of URLs of the websites to scrape", items: .init(type: .string))
                                    ]
                                 )
                         )
            )
        case .googleSearch:
            return .init(function:
                    .init(name: "googleSearch",
                          description: "If your preexisting knowledge does not contain info of the user's question, you may use this function to make a google search and retrieve the user's content. if a url has been explicitly given already, use the urlScape function instead. Always prioritize your pre-existing knowledge. Only use this function if the requested info is beyond your knowledge cutoff date. In the case where a google search will help you find the user's question's answer, come up with a meaningful search query to search google with and call the function with it. You will be receiving some website links and a small snippet from that webpage. Usually, the snippets should suffice to answer the user's question. If you feel the user might have made a typo, ask for clarification before searching with google. If you feel the google search does not sufficiently answer the user's query, use your url scraping function to retrieve any of the websites from the search results.",
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
    
    static func countTokensForAllCases() -> Int {
        var totalTokenCount = 0
        for tool in ChatTool.allCases {
            let description = tool.completionToolParam.function.description
            let tokenCountForDescription = tokenCount(text: description ?? "")
            totalTokenCount += tokenCountForDescription
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
            Text("Extract PDF")
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

struct VisionConfigurationView: View {
    @ObservedObject var appConfig = AppConfiguration.shared
    
    var body: some View {
        Form {
            Section("Ask the assistant to recognize the content of an image.") {
                Picker("Visiom Provider", selection: appConfig.$visionProvider) {
                    ForEach(Provider.allCases, id: \.self) { provider in
                        Text(provider.name)
                            .tag(provider.rawValue)
                    }
                }

//                Picker("Image Model", selection: appConfig.$visionModel) {
//                    ForEach(appConfig.visionProvider.visionModels, id: \.self) { model in
//                        Text(model.name)
//                            .tag(model.rawValue)
//                    }
//                }
            }
        }
    #if os(macOS)
        .frame(maxWidth: 400)
    #else
        .navigationBarTitle("Vision")
    #endif
    }
}
