//
//  AppIconMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/10/2024.
//

#if !os(macOS)
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    static let shared = AppDelegate()
    var chatVM: ChatSessionVM?

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
}


class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleQuickAction(shortcutItem: shortcutItem)
        completionHandler(true)
    }
    
    func handleQuickAction(shortcutItem: UIApplicationShortcutItem) {
        switch shortcutItem.type {
        case "camera":
            if let chatVM = AppDelegate.shared.chatVM {
                let session = chatVM.createNewSession()
                if let session = session {
                    session.showCamera.toggle()
                }
            }
        case "newchat":
            if let chatVM = AppDelegate.shared.chatVM {
                chatVM.createNewSession()
            }
        default:
            break
        }
    }
}
#endif
