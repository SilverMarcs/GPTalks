////
////  OpenAIService.swift
////  GPTMessage
////
////  Created by Zabir Raihan on 07/11/2023.
////
//
//import Foundation
//
//class OpenAIService: BaseChatService {
//    
//    override var baseURL: String {
//        return "https://api.openai.com"
//    }
//    
//    override var path: String {
//        return "/v1/chat/completions"
//    }
//    
//    override var headers: [String: String] {
//        [
//            "Content-Type": "application/json",
//            "Authorization": "Bearer \(AppConfiguration.shared.OAIkey)",
//        ]
//    }
//    
//}
