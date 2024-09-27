//
//  ImageWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/09/2024.
//

import SwiftUI

struct ImageWindow: Scene {
    @Environment(\.modelContext) private var modelContext
    
    var body: some Scene {
        Window("Images", id: "images") {
            ImageContentView()
        }
    }
}
