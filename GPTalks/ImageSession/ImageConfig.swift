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
    var model: AIModel
    
    var numImages: Int = ImageConfigDefaults.shared.numImages
    var size: ImagesQuery.Size = ImageConfigDefaults.shared.size
    var quality: ImagesQuery.Quality = ImageConfigDefaults.shared.quality
    var style: ImagesQuery.Style = ImageConfigDefaults.shared.style
    
    init(provider: Provider) {
        self.provider = provider
        self.model = provider.imageModel
    }
    
    init(provider: Provider, model: AIModel) {
        self.provider = provider
        self.model = model
    }
    
    func copy() -> ImageConfig {
        let copy = ImageConfig(provider: provider, model: model)
        copy.numImages = numImages
        copy.size = size
        copy.quality = quality
        copy.style = style
        return copy
    }
}
