//
//  Conversation.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/3.
//

import SwiftUI
import OpenAI

struct Conversation: Codable, Identifiable, Hashable {
    var id = UUID()
    var date = Date()
    var role: String
    var content: String
    var isReplying: Bool = false
    
    func toChat() -> Chat {
        return Chat(role: role == "user" ? .user : .system, content: content)
    }
}


