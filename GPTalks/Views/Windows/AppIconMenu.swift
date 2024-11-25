//
//  AppIconMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/10/2024.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    static let shared = AppDelegate()
    var chatVM: ChatVM?

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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Task {
                        await chatVM.createNewChat()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            AppConfig.shared.showCamera = true
                        }
                    }
                }
            }
        case "newchat":
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Task {
                    if let chatVM = AppDelegate.shared.chatVM {
                        await chatVM.createNewChat()
                    }
                }
            }
        default:
            break
        }
    }
}
