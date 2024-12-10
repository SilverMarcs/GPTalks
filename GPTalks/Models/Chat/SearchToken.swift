//
//  ChatSearchToken.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/11/2024.
//

import Foundation

enum ChatSearchToken: String, Identifiable, Hashable, CaseIterable {
    case title
    case messages
    var id: Self { self }
    
    var name: String {
        switch self {
        case .title: return "Titles"
        case .messages: return "Messages"
        }
    }
}
