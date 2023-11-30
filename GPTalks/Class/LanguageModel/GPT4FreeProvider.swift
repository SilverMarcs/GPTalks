//
//  GPT4FreeProvider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/11/2023.
//

import SwiftUI

enum GPT4FreeProvider: String, Codable, CaseIterable {
    case bing
    case liaobots
    case geekgpt
    case phind
    
    var name: String {
        switch self {
        case .bing:
            return "Bing"
        case .liaobots:
            return "LiaoBots"
        case .geekgpt:
            return "GeekGPT"
        case .phind:
            return "Phind"
        }
    }
    
    var id: String {
        switch self {
        case .bing:
            return "bing"
        case .liaobots:
            return "liaobots"
        case .geekgpt:
            return "geekgpt"
        case .phind:
            return "phind"
        }
    }
    
    static let providers: [GPT4FreeProvider] = [.bing, .liaobots, .geekgpt, .phind]
}
