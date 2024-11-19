//
//  GPTalksApp.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import TipKit

@main
struct GPTalksApp: App {
    @State private var chatVM: ChatVM = ChatVM()
    @State private var imageVM: ImageVM = ImageVM()
    @State private var settingsVM: SettingsVM = SettingsVM()
    
    #if !os(macOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        WindowScenes()
            .commands { MenuCommands() }
            .environment(chatVM)
            .environment(imageVM)
            .environment(settingsVM)
            .modelContainer(DatabaseService.shared.container)
    }
    
    init() {
//        #if DEBUG
//        try? Tips.resetDatastore()
//        #endif        
        try? Tips.configure()

        #if os(macOS)
        AppConfig.shared.hideDock = false

        QuickPanelWindow(
            chatVM: chatVM,
            modelContext: DatabaseService.shared.container.mainContext
        )

        #else
        // TODO: find a way to avoid having chatVM in app delegate
        AppDelegate.shared.chatVM = _chatVM.wrappedValue
        #endif
    }
}

