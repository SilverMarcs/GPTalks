//
//  MainWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/08/2024.
//

import SwiftUI

#if os(macOS)
struct ChatWindow: Scene {
    @State private var isQuick = false
    
    var body: some Scene {
        Window("Chats", id: "chats") {
            ChatContentView()
                .environment(\.isQuick, isQuick)
        }
    }
}
#endif
