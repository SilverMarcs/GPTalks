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
    
    var prompt: String
    var numImages: Int = ImageConfigDefaults.shared.numImages
    var size: ImagesQuery.Size = ImageConfigDefaults.shared.size
    var quality: ImagesQuery.Quality = ImageConfigDefaults.shared.quality
    var style: ImagesQuery.Style = ImageConfigDefaults.shared.style
    
    init(prompt: String = "", provider: Provider) {
        self.prompt = prompt
        self.provider = provider
        self.model = provider.imageModel
    }
    
    init(prompt: String = "", provider: Provider, model: AIModel) {
        self.prompt = prompt
        self.provider = provider
        self.model = model
    }
    
    func copy(prompt: String) -> ImageConfig {
        let copy = ImageConfig(provider: provider, model: model)
        copy.prompt = prompt
        copy.numImages = self.numImages
        copy.size = self.size
        copy.quality = self.quality
        copy.style = self.style
        return copy
    }
}
