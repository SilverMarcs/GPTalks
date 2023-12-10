//
//  ChatGPTApp.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI

@main
struct GPTalks: App {
    @State var showOpenAIKeyAlert = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear() {
                    if AppConfiguration.shared.OAIkey.isEmpty {
                        showOpenAIKeyAlert = true
                    }
                }
                .alert("Enter OpenAI API Key", isPresented: $showOpenAIKeyAlert) {
                    TextField("OpenAI API Key", text: AppConfiguration.shared.$OAIkey)
                    Button("Later", role: .cancel) { }
                    Button("Confirm", role: .none) { }
                } message: {
                    Text("You need set OpenAI API Key before start a conversation.")
                }
        }
#if os(macOS)
        Settings {
            MacOSSettingsView()
        }
#endif
    }
}
