//
//  ImageConfig.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import Foundation
import SwiftOpenAI
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
    var size: Dalle.Dalle2ImageSize = ImageConfigDefaults.shared.size
    
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
        return copy
    }
}
