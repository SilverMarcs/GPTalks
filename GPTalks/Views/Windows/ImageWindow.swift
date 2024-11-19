//
//  ImageWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/09/2024.
//

#if os(macOS)
import SwiftUI

struct ImageWindow: Scene {
    var body: some Scene {
        Window("Images", id: "images") {
            ImageContentView()
        }
    }
}
#endif
