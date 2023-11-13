//
//  Extnsions.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI

extension String {
    func copyToPasteboard() {
#if os(iOS)
        UIPasteboard.general.string = self
#else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self, forType: .string)
#endif
    }
}

//    internal func trimConversation(with input: String) -> [Message] {
//        var trimmedMessages = [Message]()
//        if trimmedMessagesIndex > messages.endIndex - 1 {
//            trimmedMessages.append(Message(role: "user", content: input))
//        } else {
//            trimmedMessages += messages[trimmedMessagesIndex...]
//            trimmedMessages.append(Message(role: "user", content: input))
//        }
//
//        let maxToken = 4096
//        var tokenCount = trimmedMessages.tokenCount
//        while tokenCount > maxToken {
//            print(trimmedMessages.remove(at: 0))
//            trimmedMessagesIndex += 1
//            print("trimmedMessagesIndex: \(trimmedMessagesIndex)")
//            tokenCount = trimmedMessages.tokenCount
//            print("tokenCount:\(tokenCount)")
//        }
//
//        trimmedMessages.insert(Message(role: "system", content: configuration.systemPrompt), at: 0)
//
//        return trimmedMessages
//    }
