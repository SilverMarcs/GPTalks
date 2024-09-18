//
//  ImageConfigDefaults.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI
import OpenAI

class ImageConfigDefaults: ObservableObject {
    static let shared = ImageConfigDefaults()
    
    @AppStorage("numImages") var numImages: Int = 1
    @AppStorage("size") var size: ImagesQuery.Size = ImagesQuery.Size._256
    @AppStorage("quality") var quality = ImagesQuery.Quality.standard
    @AppStorage("style") var style = ImagesQuery.Style.natural
    
    @AppStorage("imageWidth") var imageWidth: Int = 100
    @AppStorage("imageHeight") var imageHeight: Int = 48
}
