//
//  AIProvider.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import Foundation

//struct Model: Codable, Hashable {
//   let name: String
//   let id: String
//}


enum AIProvider: String, CaseIterable, Codable {
   case openAI
   case openRouter
    case pAI
//
//   var id: RawValue {
//       return rawValue
//   }
    
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

enum Model: String, Codable {
    /// openai
   case gpt3
   case gpt4
    
    /// openrouter
   case phind
   case codellama
   case mistral
   case mythomax
    case palm
    case palmcode
    
    /// pawan
    case pai
    case pailight
    
    var name: String {
        switch self {
        case .gpt3:
            return "GPT-3"
        case .gpt4:
            return "GPT-4"
        case .phind:
            return "Phind"
        case .codellama:
            return "CodeLlama"
        case .mistral:
            return "Mistral"
        case .mythomax:
            return "MythoMax"
        case .palm:
            return "Palm"
        case .palmcode:
            return "GCode"
        case .pai:
            return "PAI"
        case .pailight:
            return "PAI-L"
        }
    }

   var id: String {
       switch self {
       case .gpt3:
           return "gpt-3.5-turbo-1106"
       case .gpt4:
           return "gpt-4-1106-preview"
       case .phind:
           return "phind/phind-codellama-34b-v2"
       case .codellama:
           return "meta-llama/codellama-34b-instruct"
       case .mistral:
           return "open-orca/mistral-7b-openorca"
       case .mythomax:
           return "gryphe/mythomax-l2-13b"
       case .palm:
           return "google/palm-2-chat-bison"
       case .palmcode:
           return "google/palm-2-codechat-bison"
       case .pai:
           return "pai-001-beta"
       case .pailight:
           return "pai-001-light-beta"
       }
   }
    
    var maxTokens: Int {
        switch self {
        case .gpt3, .gpt4, .phind, .codellama, .mistral, .mythomax, .pai, .pailight:
            return 4000
        case .palm, .palmcode:
            return 2000
        }
    }

   static let openAIModels: [Model] = [.gpt3, .gpt4]
    static let openRouterModels: [Model] = [.phind, .codellama, .mistral, .mythomax, .palm, .palmcode]
    static let pAIModels: [Model] = [.pai, .pailight]
}
