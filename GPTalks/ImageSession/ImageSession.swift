//
//  ImageSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class ImageSession {
    var id: UUID = UUID()
    var date: Date = Date()
    var order: Int = 0
    var title: String = "Image Session"
    var isStarred: Bool = false
    @Attribute(.ephemeral)
    var prompt: String = ""

    @Relationship(deleteRule: .cascade, inverse: \ImageGeneration.session)
    var imageGenerations = [ImageGeneration]()
    
    @Relationship(deleteRule: .cascade)
    var config: ImageConfig

    init(config: ImageConfig) {
        self.config = config
    }
    
    @MainActor
    func send() async {

//        let query = ImagesQuery(prompt: prompt,
//                                model: config.model.code,
//                                n: config.numImages,
//                                quality: config.quality,
//                                size: config.size)

        
        let generation = ImageGeneration(prompt: self.prompt, config: config, session: self)

//        withAnimation {
        imageGenerations.append(generation)
//        }

        await generation.send()
        
//        if let index = generations.firstIndex(where: { $0.id == tempImageGeneration.id }) {
//            await generations[index].send(query: query, configuration: configuration)
//        }

    }
    
}

