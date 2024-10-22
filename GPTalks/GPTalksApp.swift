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
    @State private var chatVM: ChatSessionVM
    @State private var imageVM: ImageSessionVM
    @State private var listStateVM: ListStateVM
    
    #if !os(macOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        Group {
            #if os(macOS)
            ChatWindow()
            ImageWindow()
            SettingsWindow()
//            QuickPanelWindow()
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
        // Initialize the DatabaseService and perform setup.
        let dbService = DatabaseService.shared
        dbService.initialSetup(modelContext: dbService.container.mainContext)

        // Now that the database service is set up, initialize the state variables.
        _chatVM = State(initialValue: ChatSessionVM(modelContext: dbService.container.mainContext))
        _imageVM = State(initialValue: ImageSessionVM(modelContext: dbService.container.mainContext))
        _listStateVM = State(initialValue: ListStateVM())
        
        try? Tips.configure()

        #if os(macOS)
        NSWindow.allowsAutomaticWindowTabbing = false
        AppConfig.shared.hideDock = false
        #else
        AppDelegate.shared.chatVM = _chatVM.wrappedValue
        #endif
    }
}
