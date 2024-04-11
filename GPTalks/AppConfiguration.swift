//
//  AppConfiguration.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI
import OpenAI

class AppConfiguration: ObservableObject {
    
    static let shared = AppConfiguration()
    
    /// common
    @AppStorage("configuration.isMarkdownEnabled") var isMarkdownEnabled: Bool = true
    @AppStorage("configuration.alternateMarkdown") var alternateMarkdown: Bool = false
    @AppStorage("configuration.isAutoGenerateTitle") var isAutoGenerateTitle: Bool = true
    @AppStorage("configuration.autoResume") var autoResume: Bool = true
    @AppStorage("configuration.smootherScrolling") var smootherScrolling: Bool = true
    
    @AppStorage("configuration.preferredChatService") var preferredChatService: Provider = .openai
    @AppStorage("configuration.preferredImageService") var preferredImageService: Provider = .openai
    
    // Google Search
    @AppStorage("configuration.googleApiKey") var googleApiKey = ""
    @AppStorage("configuration.googleSearchEngineId") var googleSearchEngineId = ""
    
    // URLScrape
    @AppStorage("configuration.useExperimentalWebScraper") var useExperimentalWebScraper: Bool = false
    
    // ImageGenerate
    @AppStorage("configuration.imageProvider") var imageProvider: Provider = .openai
    @AppStorage("configuration.imageModel") var imageModel: Model = .dalle3
    
    // Vision
    @AppStorage("configuration.visionProvider") var visionProvider: Provider = .openai
    
    // Transcription
    @AppStorage("configuration.transcriptionProvider") var transcriptionProvider: Provider = .openai
    @AppStorage("configuration.transcriptionModel") var transcriptionModel: Model = .whisper1
    @AppStorage("configuration.alternateAudioPlayer") var alternateAudioPlayer: Bool = false
    
    // config
    @AppStorage("configuration.contextLength") var contextLength = 10
    @AppStorage("configuration.temperature") var temperature: Double = 0.5
    @AppStorage("configuration.systemPrompt") var systemPrompt: String = "You are a helpful assistant."    
        
    /// openAI
    @AppStorage("configuration.OAIKey") var OAIkey = ""
    @AppStorage("configuration.OAImodel") var OAImodel: Model = .gpt3t
    @AppStorage("configuration.OAIImageModel") var OAIImageModel: Model = .dalle3
    @AppStorage("configuration.OAIColor") var OAIColor: ProviderColor = .greenColor

    /// oxygen
    @AppStorage("configuration.Okey") var Okey = ""
    @AppStorage("configuration.Omodel") var Omodel: Model = .gpt4t
    @AppStorage("configuration.OImageModel") var OImageModel: Model = .icbinp
    @AppStorage("configuration.OColor") var OColor: ProviderColor = .niceColor
    
    /// naga
    @AppStorage("configuration.Nkey") var Nkey = ""
    @AppStorage("configuration.Nmodel") var Nmodel: Model = .gpt4t
    @AppStorage("configuration.NImageModel") var NImageModel: Model = .nplaygroundv25
    @AppStorage("configuration.NColor") var NColor: ProviderColor = .blueColor
    
    /// kraken
    @AppStorage("configuration.Kkey") var Kkey = ""
    @AppStorage("configuration.Kmodel") var Kmodel: Model = .gpt4t
    @AppStorage("configuration.KImageModel") var KImageModel: Model = .sdxl
    @AppStorage("configuration.KColor") var KColor: ProviderColor = .tealColor
    
    /// shard
    @AppStorage("configuration.Skey") var Skey = ""
    @AppStorage("configuration.Smodel") var Smodel: Model = .gpt4t
    @AppStorage("configuration.SImageModel") var SImageModel: Model = .realisticvision
    @AppStorage("configuration.SColor") var SColor: ProviderColor = .pinkColor
    
    /// custom
    @AppStorage("configuration.Ckey") var Ckey = ""
    @AppStorage("configuration.Chost") var Chost: String = ""
    @AppStorage("configuration.Cmodel") var Cmodel: Model = .gpt4t
    @AppStorage("configuration.CImageModel") var CImageModel: Model = .dalle3
    @AppStorage("configuration.CColor") var CColor: ProviderColor = .orangeColor
    
    @AppStorage("configuration.customChatModel") var customChatModel: String = ""
    @AppStorage("configuration.customImageModel") var customImageModel: String = ""
    @AppStorage("configuration.customVisionModel") var customVisionModel: String = ""
}
