//
//  ChatGPTApp.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/22.
//

import SwiftUI

@main
struct GPTalks: App {
    
    let persistenceController = PersistenceController.shared
    
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
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
#if os(macOS)
        Settings {
            MacOSSettingsView()
        }
#endif
    }
}
