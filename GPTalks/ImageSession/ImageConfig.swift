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
    
    var session: ImageSession?
    
    var numImages: Int = ImageConfigDefaults.shared.numImages
    var size: ImagesQuery.Size = ImageConfigDefaults.shared.size
    var quality: ImagesQuery.Quality = ImageConfigDefaults.shared.quality
    var style: ImagesQuery.Style = ImageConfigDefaults.shared.style
    
    init(provider: Provider = Provider.factory(type: .openai)) {
        self.provider = provider
        self.model = provider.imageModel
    }
}
