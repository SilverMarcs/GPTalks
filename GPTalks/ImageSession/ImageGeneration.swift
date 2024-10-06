//
//  ImageGeneration.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class ImageGeneration {
    var id: UUID = UUID()
    var date: Date = Date()
    
    var session: ImageSession?
    
    var prompt: String
    var errorMessage: String = ""
    
    @Relationship(deleteRule: .nullify)
    var config: ImageConfig
    
    var images: [Data] = []
    
    @Attribute(.ephemeral)
    var state: GenerationState
    
    @Transient
    var generatingTask: Task<Void, Error>?

    init(prompt: String, config: ImageConfig, session: ImageSession) {
        self.prompt = prompt
        self.config = config
        self.session = session
        self.state = .generating
    }
    
    @MainActor
    func send() async {
        state = .generating

        generatingTask = Task {
            do {
                let dataObjects = try await ImageGenerator.generateImages(
                    provider: config.provider,
                    model: config.provider.imageModel,
                    prompt: prompt,
                    numberOfImages: config.numImages
                )
                
                self.images = dataObjects
                state = .success
            } catch {
                if state != .error {
                    errorMessage = "Error fetching images: \(error)"
                    state = .error
                }
            }
        }

        do {
            #if os(macOS)
            try await generatingTask?.value
            #else
            let application = UIApplication.shared
            let taskId = application.beginBackgroundTask {
                // Handle expiration of background task here
            }

            try await generatingTask?.value

            application.endBackgroundTask(taskId)
            #endif
        } catch {
            errorMessage = error.localizedDescription
            state = .error
        }
        
        if let proxy = session?.proxy {
            scrollToBottom(proxy: proxy, delay: 0.2)
        }
    }
    
    @MainActor
    func stopGenerating() {
        generatingTask?.cancel()
        state = .error
        errorMessage = "Generation was stopped"
    }
    
    func deleteSelf() {
        session?.deleteGeneration(self)
    }
}

enum GenerationState: Codable {
    case generating
    case success
    case error
}
