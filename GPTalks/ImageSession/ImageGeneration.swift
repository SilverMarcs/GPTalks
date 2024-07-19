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
    var isGenerating: Bool = false
    @Transient
    var generatingTask: Task<Void, Error>?
    
//    init(config: ImageConfig) {
//        self.config = config
//    }
    
    init(prompt: String, config: ImageConfig, session: ImageSession) {
        self.prompt = prompt
        self.config = config
        self.session = session
    }
    
    @MainActor
    func send() async {
        isGenerating = true

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
                    print("line 62", urlResult.url)
                    if let urlString = urlResult.url, let url = URL(string: urlString) {
                        print("line 64", urlString)
                        do {
                            let (data, _) = try await URLSession.shared.data(from: url)
                            
                            #if os(macOS)
                            if let platformImage = NSImage(data: data) {
                                if let savedPath = platformImage.save() {
//                                    await MainActor.run {
                                        self.imagePaths.append(savedPath)
//                                    }
                                }
                            }
                            #else
                            if let platformImage = UIImage(data: data) {
                                if let savedPath = platformImage.save() {
//                                    await MainActor.run {
                                        self.imagePaths.append(savedPath)
//                                    }
                                }
                            }
                            #endif
                        } catch {
                            errorMessage = "Error downloading image: \(error)"
                        }
                    }
                }
            } catch {
                errorMessage = "Error fetching images: \(error)"
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
            isGenerating = false
        } catch {
            errorMessage = error.localizedDescription
            isGenerating = false
        }
    }
    
    @MainActor
    func stopGenerating() {
        generatingTask?.cancel()
        errorMessage = "Generation was stopped"
        isGenerating = false
    }
}
