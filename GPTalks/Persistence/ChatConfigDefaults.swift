//
//  ChatConfigDefaults.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI

class ChatConfigDefaults: ObservableObject {
    static let shared = ChatConfigDefaults()
    private init() {}
    
    @AppStorage("temperature") private var storedTemperature: Double?
    @AppStorage("presencePenalty") private var storedPresencePenalty: Double?
    @AppStorage("frequencyPenalty") private var storedFrequencyPenalty: Double?
    @AppStorage("topP") private var storedTopP: Double?
    @AppStorage("maxTokens") private var storedMaxTokens: Int?
    @AppStorage("stream") var stream: Bool = true
    @AppStorage("useCache") var useCache: Bool = false
    @AppStorage("systemPrompt") var systemPrompt: String = "You are a helpful assistant."
    
    @AppStorage("bedrockAccessKey") var bedrockAccessKey: String = ""
    @AppStorage("bedrockSecretKey") var bedrockSecretKey: String = ""
    @AppStorage("bedrockRegion") var bedrockRegion: String = "us-east-1"
    
    var temperature: Double? {
        get { storedTemperature }
        set { storedTemperature = newValue }
    }
    var presencePenalty: Double? {
        get { storedPresencePenalty }
        set { storedPresencePenalty = newValue }
    }
    var frequencyPenalty: Double? {
        get { storedFrequencyPenalty }
        set { storedFrequencyPenalty = newValue }
    }
    var topP: Double? {
        get { storedTopP }
        set { storedTopP = newValue }
    }
    var maxTokens: Int? {
        get { storedMaxTokens }
        set { storedMaxTokens = newValue }
    }
}
