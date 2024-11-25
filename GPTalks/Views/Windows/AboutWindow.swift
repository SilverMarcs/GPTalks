//
//  AboutWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/11/2024.
//

import SwiftUI

struct AboutWindow: Scene {
    var body: some Scene {
        Window("About", id: "about") {
            AboutSettings()
                .padding(.top, -19)
                .padding(.horizontal, 5)
                .scrollDisabled(true)
                .scrollContentBackground(.hidden)
                .frame(minWidth: 325, maxWidth: 325, minHeight: 388, maxHeight: 388)
                .windowMinimizeBehavior(.disabled)
        }
        .windowStyle(.hiddenTitleBar)
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
    }
}
