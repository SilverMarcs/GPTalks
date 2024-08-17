//
//  QuickPanelWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/08/2024.
//

import SwiftUI

struct QuickPanelWindow: Scene {
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    @State private var showAdditionalContent = false
    @State var maxHeight: CGFloat = Self.height
    @FocusState private var isWindowFocused: Bool

    var body: some Scene {
        Window("Quick Panel", id: "quick") {
            QuickPanelHelper(showAdditionalContent: $showAdditionalContent)
                .focusable()
                .focused($isWindowFocused)
                .onChange(of: isWindowFocused) {
                    if !isWindowFocused {
                        dismissWindow(id: "quick")
                    }
                }
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
}
