//
//  ImageConfig.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import Foundation
import OpenAI
import SwiftData

@Model
class ImageConfig {
    var id: UUID = UUID()
    var date: Date = Date()
    
    @Relationship(deleteRule: .nullify)
    var provider: Provider
    @Relationship(deleteRule: .nullify)
    var model: Model
    
    var numImages: Int = 1
    var size: ImagesQuery.Size = ImagesQuery.Size._256
    var quality: ImagesQuery.Quality = ImagesQuery.Quality.standard
    var style: ImagesQuery.Style = ImagesQuery.Style.natural
    
    init(provider: Provider, model: Model) {
        self.provider = provider
        self.model = model
    }
}
