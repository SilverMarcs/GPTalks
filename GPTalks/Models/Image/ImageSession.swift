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
    var title: String = "Image Session"
    @Attribute(.ephemeral)
    var prompt: String = ""

    @Relationship(deleteRule: .cascade, inverse: \Generation.session)
    var imageGenerations = [Generation]()
    
    @Relationship(deleteRule: .cascade)
    var config: ImageConfig
    
    @Transient
    var proxy: ScrollViewProxy?

    init(config: ImageConfig) {
        self.config = config
    }
    
    @MainActor
    func send() async {        
        guard !prompt.isEmpty else { return }
        
        let generation = Generation(config: config.copy(prompt: prompt), session: self)

        imageGenerations.append(generation)
        
        if let proxy = proxy {
            scrollToBottom(proxy: proxy, delay: 0.2)
        }

        await generation.send()
    }
    
    @MainActor
    func generateTitle(forced: Bool = false) async {
        if forced || imageGenerations.count == 1 {
            if let newTitle = await TitleGenerator.generateImageTitle(generations: imageGenerations, provider: config.provider) {
                self.title = newTitle
            }
        }
    }
    
    func deleteGeneration(_ generation: Generation) {
        imageGenerations.removeAll(where: { $0 == generation })
        modelContext?.delete(generation)
    }
    
    func deleteAllGenerations() {
        while let generation = imageGenerations.popLast() {
            modelContext?.delete(generation)
        }
    }
}

