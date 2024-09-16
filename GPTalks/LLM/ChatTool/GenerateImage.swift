//
//  GenerateImage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import Foundation
import OpenAI
import GoogleGenerativeAI
import SwiftData

struct GenerateImage {
    
    static func generateImage(from arguments: String, modelContext: ModelContext?) async -> ToolData {
        guard let modelContext = modelContext else {
            return .init(string: "Error: Model context not found")
        }
        
        let parameters = getImageGenerationParameters(from: arguments)
        
        let config = ImageConfigDefaults.shared
        
        let fetchProviders = FetchDescriptor<Provider>()
        let fetchedProviders = try! modelContext.fetch(fetchProviders)
        
        guard let provider = ProviderManager.shared.getImageProvider(providers: fetchedProviders) else {
            return .init(string: "Error: No image provider")
        }
        
        let service = OpenAI(
            configuration: OpenAI.Configuration(
                token: provider.apiKey, host: provider.host))
        
        let query = ImagesQuery(prompt: parameters.prompt,
                                model: provider.imageModel.code,
                                n: parameters.n ?? 1,
                                quality: config.quality,
                                size: config.size)
        
        do {
            let results = try await service.images(query: query)
            var dataObjects: [Data] = []

            for urlResult in results.data {
                if let urlString = urlResult.url, let url = URL(string: urlString) {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    dataObjects.append(data)
                }
            }

            // Now `dataObjects` contains all the Data objects fetched from the URLs
            return .init(string: "Provider: \(provider.name)\nModel: \(provider.imageModel.name)\nQuality: \(config.quality)\nSize: \(config.size)",
                         data: dataObjects)
        } catch {
            return .init(string: "Error: \(error.localizedDescription)")
        }

    }
    
    struct ImageGenerationParameters: Codable {
        let prompt: String
        let n: Int?
    }

    private static func getImageGenerationParameters(from jsonString: String) -> ImageGenerationParameters {
        let jsonData = jsonString.data(using: .utf8)!
        let parameters = try! JSONDecoder().decode(ImageGenerationParameters.self, from: jsonData)
        return parameters
    }
    
    static var openai: ChatQuery.ChatCompletionToolParam {
        return .init(
            function:
                .init(
                    name: "imageGenerate",
                    description:
                        "If the user asks to generate an image with a description of the image, create a prompt that dalle, an AI image creator, can use to generate the image(s). You may modify the user's such that dalle can create a more aesthetic and visually pleasing image. You may also specify the number of images to generate based on users request. If the user did not specify number, generate one image only.",
                    parameters:
                        .init(
                            type: .object,
                            properties: [
                                "prompt":
                                    .init(
                                        type: .string,
                                        description: "The prompt for dalle"),
                                "n":
                                    .init(
                                        type: .integer,
                                        description:
                                            "The number of images to generate"),
                            ]
                        )
                ))
    }
    
    static var google: Tool {
        Tool(functionDeclarations: [
            FunctionDeclaration(
                name: "imageGenerate",
                description: """
                             If the user asks to generate an image with a description of the image, create a prompt that dalle, an AI image creator, can use to generate the image(s). You may modify the user's such that dalle can create a more aesthetic and visually pleasing image. You may also specify the number of images to generate based on users request. If the user did not specify number, generate one image only.
                             """,
                parameters: [
                    "prompt": Schema(
                        type: .string,
                        description: "The prompt for dalle"
                    ),
                    "n": Schema(
                        type: .integer,
                        description: "The number of images to generate"
                    )
                ],
                requiredParameters: ["prompt"]
            )
        ])
    }

}
