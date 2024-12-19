//
//  Model.swift
//  GPTalks
//
//  Created by Zabir Raihan on 11/11/2023.
//

import Foundation
import OpenAI

enum Model: String, Codable {
    case gpt4o
    case gpt4o_mini
    case dalle2
    case dalle3
    
    /// custom
    case customChat
    case customVision
    case customImage

    var name: String {
        switch self {
        case .gpt4o:
            "GPT-4o"
        case .gpt4o_mini:
            "GPT-4om"
        case .dalle2:
            "DALL·E·2"
        case .dalle3:
            "DALL·E·3"


        case .customChat:
            self.id.isEmpty ? "Custom Chat" : self.id
        case .customVision:
            self.id.isEmpty ? "Custom Vision" : self.id
        case .customImage:
            self.id.isEmpty ? "Custom Image" : self.id
        }
    }

    var id: String {
        switch self {
        case .gpt4o:
            "gpt-4o"
        case .gpt4o_mini:
            "gpt-4o-mini"
        case .dalle2:
            "dall-e-2"
        case .dalle3:
            "dall-e-3"
      
        case .customChat:
            AppConfiguration.shared.customChatModel
        case .customVision:
            AppConfiguration.shared.customVisionModel
        case .customImage:
            AppConfiguration.shared.customImageModel

        }
    }
    /// OpenAI
    static let openAIChatModels: [Model] =
        [
            .gpt4o,
            .gpt4o_mini,
        ]
    
    static let openAIImageModels: [Model] =
        [
            .dalle3,
        ]
}
