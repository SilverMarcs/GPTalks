//
//  MainWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/08/2024.
//

#if os(macOS)
import SwiftUI

struct ChatWindow: Scene {

    var body: some Scene {
        Window("Chats", id: "chats") {
            ChatContentView()
                .pasteHandler()
        }
        .commands {
            ChatCommands()
        }
    }
}
#endif

