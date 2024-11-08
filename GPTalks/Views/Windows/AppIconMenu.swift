//
//  AppIconMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/10/2024.
//

import SwiftUI

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    private var aboutBoxWindowController: NSWindowController?

    func showAboutPanel() {
        if aboutBoxWindowController == nil {
            let styleMask: NSWindow.StyleMask = [.closable, .titled]
            let window = NSWindow(
                contentRect: NSRect(x: 100, y: 100, width: 400, height: 403),
                styleMask: styleMask,
                backing: .buffered,
                defer: false
            )
            window.title = "About GPTalks"
            
            let rootView = AboutSettings(showExtra: false).scrollDisabled(true).scrollContentBackground(.hidden)
            window.contentView = NSHostingView(rootView: rootView)
            window.setContentSize(NSSize(width: 400, height: 403))
            window.titlebarAppearsTransparent = true
            window.center()
            aboutBoxWindowController = NSWindowController(window: window)
        }

        aboutBoxWindowController?.showWindow(aboutBoxWindowController?.window)
    }
}
#else

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
                    let session = chatVM.createNewSession()
                    if let session = session {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            session.showCamera.toggle()
                        }
                    }
                }
            }
        case "newchat":
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let chatVM = AppDelegate.shared.chatVM {
                    chatVM.createNewSession()
                }
            }
        default:
            break
        }
    }
}
#endif
