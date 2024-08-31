//
//  GPTalksApp.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData
import TipKit
import KeyboardShortcuts

@main
struct GPTalksApp: App {
    @State private var sessionVM = SessionVM()
    
    #if targetEnvironment(macCatalyst)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        Group {
            MainWindow()
            
            #if os(macOS)
            SettingsWindow()
            
            QuickPanelWindow()
            #endif
        }
        .environment(sessionVM)
        .modelContainer(for: models, isUndoEnabled: true)
    }
    
    #if os(macOS)
    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
        AppConfig.shared.hideDock = false
    }
    #endif
    
    let models: [any PersistentModel.Type] = [
           Session.self,
           Folder.self,
           Conversation.self,
           Provider.self,
           AIModel.self,
           ConversationGroup.self,
           SessionConfig.self,
           ImageSession.self,
           ImageGeneration.self,
           ImageConfig.self
    ]
}

#if targetEnvironment(macCatalyst)
class AppDelegate: NSObject, UIApplicationDelegate, NSToolbarDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Get reference to SessionVM
        
        
        windowScene.titlebar?.titleVisibility = .hidden
        
        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = true
        
        if let titlebar = windowScene.titlebar {
            titlebar.toolbar = toolbar
            titlebar.toolbarStyle = .unified
        }
    }
}

extension SceneDelegate: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .toggleSidebar:
            return NSToolbarItem(itemIdentifier: .toggleSidebar)
        case .print:
            return NSToolbarItem(itemIdentifier: .print)
        case .primarySidebarTrackingSeparatorItemIdentifier:
            return NSToolbarItem(itemIdentifier: .primarySidebarTrackingSeparatorItemIdentifier)
        case NSToolbarItem.Identifier("customButton1"):
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Custom 1"
            item.paletteLabel = "Custom Button 1"
            item.toolTip = "Perform Custom Action 1"
            item.image = UIImage(systemName: "square.and.pencil")
            item.target = self
//            item.action = {}
            return item
        case NSToolbarItem.Identifier("customButton2"):
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Custom 2"
            item.paletteLabel = "Custom Button 2"
            item.toolTip = "Perform Custom Action 2"
            item.image = UIImage(systemName: "square.and.pencil")
            item.target = self
//            item.action = ??
            return item
        default:
            return nil
        }
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .flexibleSpace, NSToolbarItem.Identifier("customButton1"), .primarySidebarTrackingSeparatorItemIdentifier, .flexibleSpace, NSToolbarItem.Identifier("customButton2")]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .flexibleSpace, NSToolbarItem.Identifier("customButton1"), .primarySidebarTrackingSeparatorItemIdentifier, .flexibleSpace, NSToolbarItem.Identifier("customButton2")]
    }
}
#endif
