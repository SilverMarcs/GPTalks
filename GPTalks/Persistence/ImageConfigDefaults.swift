//
//  ImageConfigDefaults.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI
import SwiftOpenAI

class ImageConfigDefaults: ObservableObject {
    static let shared = ImageConfigDefaults()
    private init() {}
    
    @AppStorage("numImages") var numImages: Int = 1
    @AppStorage("size") var size: Dalle.Dalle2ImageSize = Dalle.Dalle2ImageSize.small
    
    @AppStorage("imageWidth") var imageWidth: Int = 250
    @AppStorage("imageHeight") var imageHeight: Int = 250
    
    @AppStorage("chatImageWidth") var chatImageWidth: Int = 100
    @AppStorage("chatImageHeight") var chatImageHeight: Int = 48
}
