//
//  ProviderType.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import Foundation

enum ProviderType: Codable, CaseIterable, Identifiable {
    case openai
    case claude
    case google
    
    var id: ProviderType { self }
    
    var name: String {
        switch self {
        case .openai: "OpenAI"
        case .claude: "Claude"
        case .google: "Google"
        }
    }
}
