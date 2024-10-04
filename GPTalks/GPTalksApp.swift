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
    @State private var chatVM = ChatSessionVM(modelContext: DatabaseService.shared.container.mainContext)
    @State private var imageVM = ImageSessionVM(modelContext: DatabaseService.shared.container.mainContext)
    @State private var listStateVM = ListStateVM()
    
    #if !os(macOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        Group {
            #if os(macOS)
            ChatWindow()
            ImageWindow()
            SettingsWindow()
            QuickPanelWindow()
            #else
            IOSWindow()
            #endif
        }
        .commands { MenuCommands() }
        .environment(chatVM)
        .environment(imageVM)
        .environment(listStateVM)
        .modelContainer(DatabaseService.shared.container)
    }
    
    init() {
        #if os(macOS)
        NSWindow.allowsAutomaticWindowTabbing = false
        AppConfig.shared.hideDock = false
        #else
        AppDelegate.shared.chatVM = chatVM
        #endif
        DatabaseService.shared.initialSetup(modelContext: chatVM.modelContext)
        try? Tips.configure([.datastoreLocation(.applicationDefault)])
    }
}
