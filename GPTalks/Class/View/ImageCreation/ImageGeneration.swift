//
//  ImageObject.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/02/2024.
//

import Foundation
import OpenAI
#if os(iOS)
import UIKit
#endif

@Observable class ImageGeneration: Identifiable, Hashable, Equatable {
    static func == (lhs: ImageGeneration, rhs: ImageGeneration) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: UUID = UUID()
    var isGenerating: Bool = true
    var errorDesc: String = ""
    var prompt: String
    var model: String
    var imagesData: [Data]
    
    var generatingTask: Task<Void, Error>? = nil
    
    init(prompt: String, imageModel: String, urls: [URL] = []) {
        self.prompt = prompt
        self.model = imageModel
        self.imagesData = []
    }
    
    @MainActor
    func send(query: ImagesQuery, configuration: ImageSession.Configuration) async {
        isGenerating = true

        let openAIconfig = configuration.provider.config
        let service = OpenAI(configuration: openAIconfig)

        generatingTask = Task {
            let results = try await service.images(query: query)

            // Download and store image data asynchronously
            for urlResult in results.data {
                if let urlString = urlResult.url, let url = URL(string: urlString) {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        imagesData.append(data)
                    } catch {
                        print("Error downloading image: \(error)")
                    }
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
            isGenerating = false
        } catch {
            errorDesc = error.localizedDescription
            isGenerating = false
        }
    }
    
    @MainActor
    func stopGenerating() {
        generatingTask?.cancel()
        errorDesc = "Generation was stopped"
        isGenerating = false
    }
}
