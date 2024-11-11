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
    @State private var chatVM: ChatVM = ChatVM()
    @State private var imageVM: ImageVM = ImageVM()
    @State private var listStateVM: SettingsVM = SettingsVM()
    
    #if !os(macOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        WindowScenes()
            .commands { MenuCommands() }
            .environment(chatVM)
            .environment(imageVM)
            .environment(listStateVM)
            .modelContainer(DatabaseService.shared.container)
    }
    
    init() {
        let dbService = DatabaseService.shared
        dbService.initialSetup(modelContext: dbService.container.mainContext)

//        #if DEBUG
//        try? Tips.resetDatastore()
//        #endif
        
        try? Tips.configure()

        #if os(macOS)
        AppConfig.shared.hideDock = false
        #else
        AppDelegate.shared.chatVM = _chatVM.wrappedValue
        #endif
    }
}

