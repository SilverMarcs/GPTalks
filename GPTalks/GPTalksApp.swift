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
    @State private var googleAuth = GoogleAuth()
    
    #if targetEnvironment(macCatalyst)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        Group {
            MainWindow()
            
            #if os(macOS) || targetEnvironment(macCatalyst)
            SettingsWindow()
            #endif
            
            #if os(macOS)
            QuickPanelWindow()
            #endif
        }
        .environment(sessionVM)
        .environment(googleAuth)
        .modelContainer(DatabaseService.shared.container)
    }
    
    #if os(macOS)
    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
        AppConfig.shared.hideDock = false
    }
    #endif
    
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
        case .newSession:
            let item = NSToolbarItem(itemIdentifier: .newSession)
            let originalImage = UIImage(systemName: "square.and.pencil")
            let resizedImage = originalImage?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .regular))
            item.image = resizedImage
            item.label = "Custom Action"
            item.toolTip = "Perform Custom Action"
            item.target = self
            item.action = #selector(addNewSession)
            return item
        default:
            return nil
        }
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .flexibleSpace, .newSession, .primarySidebarTrackingSeparatorItemIdentifier, .flexibleSpace]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .flexibleSpace, .newSession, .primarySidebarTrackingSeparatorItemIdentifier, .flexibleSpace]
    }
    
    @objc func addNewSession() {
        DatabaseService.shared.createNewSession()
    }
}

extension NSToolbarItem.Identifier {
    static let newSession = NSToolbarItem.Identifier("newSession")
}

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
#endif
