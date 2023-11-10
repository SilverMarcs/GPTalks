//
//  Pawan.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI

class PAIService: BaseChatService {
    
    override var baseURL: String {
        return "https://api.pawan.krd"
    }
    
    override var path: String {
        return "/v1/chat/completions"
    }
    
    override var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(AppConfiguration.shared.PAIkey)",
        ]
    }
    
}

