//
//  QuickPanelWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/08/2024.
//

import SwiftUI
import KeyboardShortcuts

#if os(macOS)
struct QuickPanelWindow: Scene {
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @State private var isQuick = true

    @State private var showAdditionalContent = false
    @State var maxHeight: CGFloat = QuickPanelWindow.height
    @State private var isQuickPanelVisible = false
    @FocusState private var isFocused: Bool

    var body: some Scene {
        Window("Quick Panel", id: "quick") {
            QuickPanelHelper(showAdditionalContent: $showAdditionalContent)
                .environment(\.isQuick, isQuick)
                .ignoresSafeArea()
                .onChange(of: showAdditionalContent) {
                    toggleMaxHeight()
                }
                .containerBackground(.thickMaterial, for: .window)
                .frame(
                    minWidth: 650, maxWidth: 650, minHeight: maxHeight,
                    maxHeight: maxHeight
                )
                .toolbarVisibility(.hidden, for: .windowToolbar)
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }
                .onChange(of: isFocused) {
                    if !isFocused {
                        dismissWindow(id: "quick")
                    }
                }
                .onExitCommand {
                    dismissWindow(id: "quick")
                }
        }
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
        .windowLevel(.floating)
        .windowStyle(.hiddenTitleBar)
        .windowBackgroundDragBehavior(.enabled)
        .defaultWindowPlacement { content, context in
            let displayBounds = context.defaultDisplay.visibleRect
            let position = CGPoint(
                x: displayBounds.midX - 400,
                y: displayBounds.midY - 300)
            return WindowPlacement(position)
        }
    }

    func toggleMaxHeight() {
        if maxHeight == Self.height {
            maxHeight = 500
        } else {
            maxHeight = Self.height
        }
    }
    
    static var height: CGFloat = 29
    
    func setupShortcut() {
        KeyboardShortcuts.onKeyDown(for: .togglePanel) {
            if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "quick" }) {
                if window.isVisible {
                    dismissWindow(id: "quick")
                } else {
                    openWindow(id: "quick")
                    window.makeKeyAndOrderFront(nil)
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
            } else {
                openWindow(id: "quick")
                if let newWindow = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "quick" }) {
                    newWindow.makeKeyAndOrderFront(nil)
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
            }
        }
    }


    init() {
        setupShortcut()
    }

}
#endif
