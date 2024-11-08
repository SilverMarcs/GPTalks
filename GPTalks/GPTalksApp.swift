//
//  GPTalksApp.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct GPTalksApp: App {
    @State private var chatVM: ChatVM
    @State private var imageVM: ImageSessionVM
    @State private var listStateVM: ListStateVM
    
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #else
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        WindowScenes()
            .commands {
                MenuCommands()
                
                CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                    Button(action: {
                        appDelegate.showAboutPanel()
                    }) {
                        Text("About My App")
                    }
                }
            }
            .environment(chatVM)
            .environment(imageVM)
            .environment(listStateVM)
            .modelContainer(DatabaseService.shared.container)
    }
    
    init() {
        let dbService = DatabaseService.shared
        dbService.initialSetup(modelContext: dbService.container.mainContext)

        _chatVM = State(initialValue: ChatVM(modelContext: dbService.container.mainContext))
        _imageVM = State(initialValue: ImageSessionVM(modelContext: dbService.container.mainContext))
        _listStateVM = State(initialValue: ListStateVM())
        
        try? Tips.configure()

        #if os(macOS)
        AppConfig.shared.hideDock = false
        #else
        AppDelegate.shared.chatVM = _chatVM.wrappedValue
        #endif
    }
}

