//
//  SessionConfigDefaults.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI

class SessionConfigDefaults: ObservableObject {
    static let shared = SessionConfigDefaults()
    
    @AppStorage("temperature") private var storedTemperature: Double?
    @AppStorage("presencePenalty") private var storedPresencePenalty: Double?
    @AppStorage("frequencyPenalty") private var storedFrequencyPenalty: Double?
    @AppStorage("topP") private var storedTopP: Double?
    @AppStorage("maxTokens") private var storedMaxTokens: Int?
    @AppStorage("stream") var stream: Bool = true
    @AppStorage("systemPrompt") var systemPrompt: String = "You are a helpful assistant."
    
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
