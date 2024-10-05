//
//  GenerateImage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import Foundation
import SwiftOpenAI
import GoogleGenerativeAI
import SwiftData

struct GenerateImage {
    static func generateImage(from arguments: String) async throws -> ToolData {
        let modelContext = DatabaseService.shared.modelContext
        
        let parameters = getImageGenerationParameters(from: arguments)
        let config = ImageConfigDefaults.shared
        
        let fetchProviders = FetchDescriptor<Provider>()
        let fetchedProviders = try! modelContext.fetch(fetchProviders)
        
        guard let provider = ProviderManager.shared.getToolImageProvider(providers: fetchedProviders) else {
            return .init(string: "Error: No image provider")
        }
        
        do {
            let dataObjects = try await ImageGenerator.generateImages(
                provider: provider,
                model: provider.imageModel,
                prompt: parameters.prompt,
                numberOfImages: parameters.n
            )
            
            return .init(
                string: "Provider: \(provider.name)\nModel: \(provider.imageModel.name)\nSize: \(config.size)",
                data: dataObjects
            )
        } catch {
            return .init(string: "Error: \(error.localizedDescription)")
        }
    }
    
    struct ImageGenerationParameters: Codable {
        let prompt: String
        let n: Int
    }

    private static func getImageGenerationParameters(from jsonString: String) -> ImageGenerationParameters {
        let jsonData = jsonString.data(using: .utf8)!
        let parameters = try! JSONDecoder().decode(ImageGenerationParameters.self, from: jsonData)
        return parameters
    }
    
    static let tokenCount = countTokensFromText(description)
    
    static let description = """
        If the user asks to generate an image with a description of the image, create a prompt that dalle, an AI image creator, can use to generate the image(s). You may modify the user's such that dalle can create a more aesthetic and visually pleasing image. You may also specify the number of images to generate based on users request. If the user did not specify number, generate one image only.
        """

    static var openai: ChatCompletionParameters.Tool {
        return .init(
            function:
                .init(
                    name: "imageGenerate",
                    strict: false,
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
                name: "imageGenerate",
                description: description,
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
                requiredParameters: ["prompt", "n"]
            )
        ])
    }

    static var vertex: [String: Any] {
        [
            "name": "imageGenerate",
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
