//
//  ImageGenerator.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/10/2024.
//

import SwiftOpenAI
import Foundation

class ImageGenerator {
    static func generateImages(provider: Provider, model: AIModel, prompt: String, numberOfImages: Int) async throws -> [Data] {
        let service = OpenAIService.getService(provider: provider)
        let createParameters = ImageCreateParameters(
            prompt: prompt,
            model: .custom(modelCode: model.code, size: .small),
            numberOfImages: numberOfImages
        )
        let imageURLS = try await service.createImages(parameters: createParameters).data.map(\.url)
        
        var dataObjects: [Data] = []
        
        for url in imageURLS {
            if let imageUrl = url {
                do {
                    let (data, _) = try await URLSession.shared.data(from: imageUrl)
                    dataObjects.append(data)
                } catch {
                    print("Failed to download image from \(imageUrl): \(error)")
                }
            }
        }
        
        return dataObjects
    }
}
