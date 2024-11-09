//
//  ChatStatus.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/11/2024.
//

import Foundation

enum ChatStatus: Int, Codable, Identifiable, Equatable, CaseIterable {
    case normal = 1
    case starred
    case quick
    case archived
    
    var id: Int { rawValue }
    
    var name: String {
        switch self {
        case .normal: return "Normal"
        case .starred: return "Starred"
        case .quick: return "Quick"
        case .archived: return "Archived"
        }
    }
}
