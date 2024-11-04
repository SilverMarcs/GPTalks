//
//  MainWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/08/2024.
//

import SwiftUI

#if os(macOS)
struct ChatWindow: Scene {
    @State var isPresented = false
    @State var showAdditionalContent = false
    
    var body: some Scene {
        Window("Chats", id: "chats") {
            ChatContentView()
                .withFloatingPanel(isPresented: $isPresented, showAdditionalContent: $showAdditionalContent)
        }
        .commands {
            ChatCommands()
        }
    }
}
#endif

private struct ProviderKey: EnvironmentKey {
    static let defaultValue: [Provider] = []
}

extension EnvironmentValues {
    var providers: [Provider] {
        get { self[ProviderKey.self] }
        set { self[ProviderKey.self] = newValue }
    }
}

