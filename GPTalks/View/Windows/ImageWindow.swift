//
//  ImageWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/09/2024.
//

import SwiftUI

#if os(macOS)
struct ImageWindow: Scene {
    var body: some Scene {
        Window("Images", id: "images") {
            ImageContentView()
        }
    }
}
#endif
