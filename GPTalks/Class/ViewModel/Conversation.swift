//
//  Conversation.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/3.
//

import SwiftUI

enum MessageType {
    case text
    case textEdit
}

struct Conversation: Codable, Identifiable, Hashable {
    var id = UUID()
    var date = Date()
    var role: String
    var content: String
    var isReplying: Bool = false
    
    func toMessage() -> Message {
        return Message(role: role, content: content)
    }
}


