//
//  ImageGeneration.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import Foundation
import SwiftData
import OpenAI
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
    
    var imagePaths: [String] = []
    
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
    
    func sendDemo() async {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.imagePaths.append(.demoImages.randomElement()!)
            self.state = .success
            return
        }
    }
    
    @MainActor
    func send() async {
        state = .generating
        
//        #if DEBUG
//        await self.sendDemo()
//        return
//        #endif

        let service = OpenAI(
            configuration: OpenAI.Configuration(
                token: config.provider.apiKey, host: config.provider.host))
        
        let query = ImagesQuery(prompt: self.prompt,
                                model: config.model.code,
                                n: config.numImages,
                                quality: config.quality,
                                size: config.size)

        generatingTask = Task {
            do {
                let results = try await service.images(query: query)

                // Download and store image data asynchronously
                for urlResult in results.data {
                    if let urlString = urlResult.url, let url = URL(string: urlString) {
                        do {
                            let (data, _) = try await URLSession.shared.data(from: url)
                            
                            if let savedPath = PlatformImage.from(data: data)?.save() {
                                self.imagePaths.append(savedPath)
                            }
                        } catch {
                            errorMessage = "Error downloading image: \(error)"
                            state = .error
                        }
                    }
                }
            } catch {
                errorMessage = "Error fetching images: \(error)"
                state = .error
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
            state = .success
        } catch {
            errorMessage = error.localizedDescription
            state = .error
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
