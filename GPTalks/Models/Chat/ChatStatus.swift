//
//  ChatStatus.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/11/2024.
//

import SwiftUI

enum ChatStatus: Int, Codable, Identifiable, Equatable, CaseIterable {
    case normal = 1
    case starred
    case quick
    case archived
    case temporary
    
    var id: Int { rawValue }
    
    var systemImageName: String {
        switch self {
        case .normal: return "tray.circle.fill"
        case .starred: return "star.circle.fill"
        case .quick: return "bolt.fill"
        case .archived: return "archivebox.circle.fill"
        case .temporary: return "tray.circle"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .normal: return .blue
        case .starred: return .orange
        case .quick: return .yellow
        case .archived: return .gray
        case .temporary: return .black
        }
    }
    
    var name: String {
        switch self {
        case .normal: return "Chats"
        case .starred: return "Starred"
        case .quick: return "Quick"
        case .archived: return "Archived"
        case .temporary: return "Temporary"
        }
    }
}
