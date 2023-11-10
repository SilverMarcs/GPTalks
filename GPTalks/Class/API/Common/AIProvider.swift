//
//  AIProvider.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import Foundation

struct Model: Codable, Hashable {
   let name: String
   let id: String
}


enum AIProvider: String, CaseIterable, Codable {
   case openAI
   case openRouter

   var id: RawValue {
       return rawValue
   }
    
    var iconName: String {
        switch self {
        case .openAI:
            return "openaigreen"
        case .openRouter:
            return "openai"
        }
    }

   var name: String {
       switch self {
       case .openAI:
           return "OpenAI"
       case .openRouter:
           return "OpenRouter"
       }
   }
    
    var preferredModel: Model {
        switch self {
        case .openAI:
            return Model(name: "GPT-4", id: "gpt-4-1106-preview")
        case .openRouter:
            return Model(name: "Phind", id: "phind/phind-codellama-34b-v2")
        }
    }

   var models: [Model] {
       switch self {
       case .openAI:
           return [
            Model(name: "GPT-3", id: "gpt-3.5-turbo-1106"),
            Model(name: "GPT-4", id: "gpt-4-1106-preview"),
           ]
       case .openRouter:
           return [
              Model(name: "GPT-3", id: "openai/gpt-3.5-turbo-1106"),
              Model(name: "GPT-4", id: "openai/gpt-4-1106-preview"),
              Model(name: "Phind", id: "phind/phind-codellama-34b-v2"),
              Model(name: "CodeLlama", id: "meta-llama/codellama-34b-instruct"),
//              Model(name: "Llama2-70B", id: "meta-llama/llama-2-70b-chat"),
//              Model(name: "Llama2-13B", id: "meta-llama/llama-2-13b-chat"),
              Model(name: "Mistral", id: "open-orca/mistral-7b-openorca"),
//              Model(name: "Hermes", id: "nousresearch/nous-hermes-llama2-13b"),
//              Model(name: "Hermes-70B", id: "nousresearch/nous-hermes-llama2-70b"),
              Model(name: "MythoMax", id: "gryphe/mythomax-l2-13b"),
//              Model(name: "MythoMax-8k", id: "gryphe/mythomax-l2-13b-8k"),
//              Model(name: "Palm", id: "google/palm-2-chat-bison"),
//              Model(name: "GCode", id: "google/palm-2-codechat-bison")
           ]

       }
   }
}
