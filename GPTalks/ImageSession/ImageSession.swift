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
        order = 0
        
        guard !prompt.isEmpty else { return }
        
        let generation = ImageGeneration(prompt: self.prompt, config: config, session: self)

        imageGenerations.append(generation)

        await generation.send()
    }
    
    @MainActor
    func generateTitle(forced: Bool = false) async {
        if forced || imageGenerations.count == 1 {
            
        }
    }
    
    func deleteGeneration(_ generation: ImageGeneration) {
        withAnimation {
            imageGenerations.removeAll(where: { $0 == generation })
        }
    }
    
    func deleteAllGenerations() {
        withAnimation {
            imageGenerations.removeAll()
        }
    }
}

