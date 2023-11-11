//
//  AIProvider.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import Foundation

enum AIProvider: String, CaseIterable, Codable {
   case openAI
   case openRouter
    case pAI
    
    func service(configuration: DialogueSession.Configuration) -> ChatService {
       switch self {
       case .openAI:
           return OpenAIService(configuration: configuration)
       case .openRouter:
           return OpenRouterService(configuration: configuration)
       case .pAI:
           return PAIService(configuration: configuration)
       }
    }
    
    var iconName: String {
        return self.rawValue.lowercased()
    }

   var name: String {
       switch self {
       case .openAI:
           return "OpenAI"
       case .openRouter:
           return "OpenRouter"
       case .pAI:
           return "PAI"
       }
   }
    
    var contextLength: Int {
        switch self {
        case .openAI:
            return AppConfiguration.shared.OAIcontextLength
        case .openRouter:
            return AppConfiguration.shared.ORcontextLength
        case .pAI:
            return AppConfiguration.shared.PAIcontextLength
        }
    }
    
    var temperature: Double {
        switch self {
        case .openAI:
            return AppConfiguration.shared.OAItemperature
        case .openRouter:
            return AppConfiguration.shared.ORtemperature
        case .pAI:
            return AppConfiguration.shared.PAItemperature
        }
    }
    
    var systemPrompt: String {
        switch self {
        case .openAI:
            return AppConfiguration.shared.OAIsystemPrompt
        case .openRouter:
            return AppConfiguration.shared.ORsystemPrompt
        case .pAI:
            return AppConfiguration.shared.PAIsystemPrompt
        }
    }
    
    var preferredModel: Model {
        switch self {
        case .openAI:
            return AppConfiguration.shared.OAImodel
        case .openRouter:
            return AppConfiguration.shared.ORmodel
        case .pAI:
            return AppConfiguration.shared.PAImodel
        }
    }

    var models: [Model] {
        switch self {
        case .openAI:
            return Model.openAIModels
        case .openRouter:
            return Model.openRouterModels
        case .pAI:
            return Model.pAIModels
        }
    }
}

