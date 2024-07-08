//
//  Conversation.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import Foundation

import Foundation
import SwiftData
import OpenAI

@Model
final class Conversation: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Conversation(role: role, content: content)
        return copy
    }
    
    var id: UUID = UUID()
    var date: Date = Date()
    
    var group: ConversationGroup?
    var model: Model?
    
    var content: String
    var role: ChatQuery.ChatCompletionMessageParam.Role
    
    @Attribute(.ephemeral)
    var isReplying: Bool = false
    
    init(role: ChatQuery.ChatCompletionMessageParam.Role, content: String) {
        self.role = role
        self.content = content
    }
    
    init(role: ChatQuery.ChatCompletionMessageParam.Role, content: String, group: ConversationGroup) {
        self.role = role
        self.content = content
        self.group = group
    }
    
    init(role: ChatQuery.ChatCompletionMessageParam.Role, content: String, model: Model) {
        self.role = role
        self.content = content
        self.group = group
        self.model = model
    }
    
    func toQuery() -> ChatQuery.ChatCompletionMessageParam {
        let query = ChatQuery.ChatCompletionMessageParam(
            role: role,
            content: content
        )
        if let query = query {
            return query
        } else {
            fatalError("Could not create query")
        }
    }
    
    func deleteSelf() {
        group?.deleteConversation(self)
    }
}
