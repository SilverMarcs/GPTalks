//
//  WindowUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 28/07/2024.
//

import SwiftUI

#if os(macOS)
struct BackgroundAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { // Ensure this runs on the main thread
            if let window = view.window {
                window.styleMask.remove(.resizable)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

extension View {
    func windowDetector(isMainWindowActive: Binding<Bool>) -> some View {
        self
            .onAppear {
                NSWindow.allowsAutomaticWindowTabbing = false
                DispatchQueue.main.async {
                    if let window = NSApplication.shared.windows.first {
                        window.identifier = NSUserInterfaceItemIdentifier("main")
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { notification in
                if let window = notification.object as? NSWindow, window.identifier == NSUserInterfaceItemIdentifier("main") {
                    isMainWindowActive.wrappedValue = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification)) { notification in
                if let window = notification.object as? NSWindow, window.identifier == NSUserInterfaceItemIdentifier("main") {
                    isMainWindowActive.wrappedValue = false
                }
            }
    }
}
#endif
