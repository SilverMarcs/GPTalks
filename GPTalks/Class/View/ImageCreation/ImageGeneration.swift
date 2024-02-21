//
//  ImageObject.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/02/2024.
//

import Foundation
import OpenAI

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
    var urls: [URL]
    
    var generatingTask: Task<Void, Error>? = nil
    
    init(prompt: String, imageModel: String, urls: [URL] = []) {
        self.prompt = prompt
        self.model = imageModel
        self.urls = urls
    }
    
    @MainActor
    func send(query: ImagesQuery, configuration: ImageSession.Configuration) async {
        isGenerating = true
        
        let openAIconfig = configuration.provider.config
        let service = OpenAI(configuration: openAIconfig)
        
        
        generatingTask = Task {
            let results = try await service.images(query: query)
            
            let urlObjects = results.data.compactMap { urlResult -> URL? in
                guard let urlString = urlResult.url, let url = URL(string: urlString) else {
                    return nil
                }
                return url
            }
            urls = urlObjects
        }
        
        do {
            try await generatingTask?.value
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
