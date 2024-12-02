//
//  HelpWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/11/2024.
//

import SwiftUI

struct HelpWindow: Scene {
    var body: some Scene {
        UtilityWindow("Help", id: WindowID.help) {
            GuidesSettings()
                .frame(width: 400, height: 500)
        }
        .restorationBehavior(.disabled)
        .windowIdealSize(.fitToContent)
    }
}
