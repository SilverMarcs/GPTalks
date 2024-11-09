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
    
    var systemImageName: String {
        switch self {
        case .normal: return "message"
        case .starred: return "star"
        case .quick: return "bolt"
        case .archived: return "archivebox"
        }
    }
    
    var name: String {
        switch self {
        case .normal: return "Active Chats"
        case .starred: return "Starred Chats"
        case .quick: return "Quick Chats"
        case .archived: return "Archived Chats"
        }
    }
}
