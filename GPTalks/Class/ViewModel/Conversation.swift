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

//
//struct Conversation: Identifiable, Codable, Equatable {
//    
//    var id = UUID()
//    
////    var isReplying: Bool = false
//    
////    var isLast: Bool = false
//    
////    var reply: String?
//
//    var errorDesc: String?
//    
////    var date = Date()
//    
////    var preview: String {
////        if let errorDesc = errorDesc {
////            return errorDesc
////        }
//////        if reply == nil {
//////            return inputPreview
//////        }
////
////        return reply ?? ""
////    }
//    
////    private var inputPreview: String {
////        return input
////    }
//    
//    var inputType: MessageType {
//        return .text
//    }
//    
////    var replyType: MessageType {
////        guard errorDesc == nil else {
////            return .error
////        }
//////        guard let reply = reply else {
//////            return .error
//////        }
////
////        return .text
////    }
//    
//}


