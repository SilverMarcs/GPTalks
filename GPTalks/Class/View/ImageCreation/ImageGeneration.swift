//
//  ImageObject.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/02/2024.
//

import Foundation
import OpenAI

@Observable class ImageGeneration: Codable, Identifiable, Hashable {
    static func == (lhs: ImageGeneration, rhs: ImageGeneration) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: UUID = UUID()
    var isGenerating: Bool = true
    var prompt: String
    var imageModel: String
//    var provider: Provider
//    var model: Model
//    var size: ImagesQuery.Size
    var urls: [URL]
    
    init(isGenerating: Bool, prompt: String, imageModel: String, urls: [URL] = []) {
        self.prompt = prompt
        self.imageModel = imageModel
        self.urls = urls
    }
}
