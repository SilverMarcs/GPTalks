//
//  ImageGenerator.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import Foundation
import OpenAI
import GoogleGenerativeAI
import SwiftData

struct ImageGenerator: ToolProtocol {
    static let toolName: String = "imageGenerator"
    static let displayName: String = "Image Generate"
    static let icon: String = "photo"
    
    static func process(arguments: String) async throws -> ToolData {
        let modelContext = DatabaseService.shared.modelContext
        
        let parameters = getImageGenerationParameters(from: arguments)
        
        var fetchDefaults = FetchDescriptor<ProviderDefaults>()
        fetchDefaults.fetchLimit = 1
        let fetchedProviders = try modelContext.fetch(fetchDefaults)
        guard let toolImageProvider = fetchedProviders.first?.toolImageProvider else {
            throw RuntimeError("No Tool Image provider found")
        }
        
        let config: ImageConfig = .init(prompt: parameters.prompt, provider: toolImageProvider, model: toolImageProvider.toolImageModel)
        
        let dataObjects = try await ImageGenerator.generateImages(
            config: config
        )
        
        return .init(
            string: "Provider: \(toolImageProvider.name)\nModel: \(toolImageProvider.imageModel.name)\nSize: \(config.size)\nQuality: \(config.quality)\nNumber of Images: \(config.numImages)",
            data: dataObjects
        )
    }
    
    struct ImageGenerationParameters: Codable {
        let prompt: String
        let n: Int
    }
    
    static func generateImages(config: ImageConfig) async throws -> [Data] {
        let service = OpenAIService.getService(provider: config.provider)

        let query = ImagesQuery(prompt: config.prompt,
                                model: config.provider.imageModel.code,
                                n: config.numImages,
                                quality: config.quality,
                                size: config.size)
        
        var imageUrls: [String?] = []
        
        do {
            imageUrls = try await service.images(query: query).data.map(\.url)
        } catch {
            throw RuntimeError("Failed to generate images: \(error)")
        }
        
        var dataObjects: [Data] = []

        for imageUrl in imageUrls {
            if let urlString = imageUrl, let url = URL(string: urlString) {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    dataObjects.append(data)
                } catch {
                    print("Failed to download image from \(url): \(error)")
                }
            } else {
                throw RuntimeError("Invalid image URL: \(imageUrl ?? "")")
            }
        }

        return dataObjects

    }
    private static func getImageGenerationParameters(from jsonString: String) -> ImageGenerationParameters {
        let jsonData = jsonString.data(using: .utf8)!
        let parameters = try! JSONDecoder().decode(ImageGenerationParameters.self, from: jsonData)
        return parameters
    }
    
    static let description = """
        If the user asks to generate an image with a description of the image, create a prompt that dalle, an AI image creator, can use to generate the image(s). You may modify the user's such that dalle can create a more aesthetic and visually pleasing image. You may also specify the number of images to generate based on users request. If the user did not specify number, generate one image only.
        """

    static var openai: ChatQuery.ChatCompletionToolParam {
        return .init(
            function:
                .init(
                    name: toolName,
                    description: description,
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
                            ],
                            required: ["prompt", "n"]
                        )
                ))
    }

    static var google: Tool {
        Tool(functionDeclarations: [
            FunctionDeclaration(
                name: toolName,
                description: description,
                parameters: [
                    "prompt": .init(
                        type: .string,
                        description: "The prompt for dalle"
                    ),
                    "n": .init(
                        type: .integer,
                        description: "The number of images to generate"
                    )
                ],
                requiredParameters: ["prompt", "n"]
            )
        ])
    }

    static var vertex: [String: Any] {
        [
            "name": toolName,
            "description": description,
            "input_schema": [
                "type": "object",
                "properties": [
                    "prompt": [
                        "type": "string",
                        "description": "The prompt for dalle"
                    ],
                    "n": [
                        "type": "integer",
                        "description": "The number of images to generate"
                    ]
                ],
                "required": ["prompt", "n"]
            ]
        ]
    }

}
