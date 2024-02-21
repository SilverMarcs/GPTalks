//
//  ImageSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/02/2024.
//

import SwiftUI
import OpenAI

@Observable class ImageSession: Identifiable, Equatable, Hashable {
    
    static func == (lhs: ImageSession, rhs: ImageSession) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    struct Configuration: Codable {
        var count: Int
        var provider: Provider
        var model: Model
        var quality: ImagesQuery.Quality

        init() {
            count = 1
            provider = AppConfiguration.shared.preferredImageService
            model = .absolutereality_v181
            quality = .standard
        }
    }

    var id = UUID()
    var configuration = Configuration()
    var input: String = ""
    var generations: [ImageGeneration] = []
    var errorDesc: String = ""
    
    var streamingTask: Task<Void, Error>?
    
    @MainActor
    func send() async {
        errorDesc = ""

        let query = ImagesQuery(prompt: input, model: configuration.model.id, n: configuration.count, quality: configuration.quality, size: ._1024)

            streamingTask = Task {
                try await sendHelper(query: query)
            }

        do {
            
            try await streamingTask?.value

        } catch {
            errorDesc = error.localizedDescription
        }
    }
    
    @MainActor
    func sendHelper(query: ImagesQuery) async throws {
        let openAIconfig = configuration.provider.config
        let service = OpenAI(configuration: openAIconfig)
        // Step 1: Create an ImageGeneration with the prompt and empty URLs.
        let tempImageGeneration = ImageGeneration(isGenerating: true, prompt: input, imageModel: configuration.model.name)

        // Add this temporary object to your collection.
        generations.append(tempImageGeneration)

        // Step 2: Perform the asynchronous operation to fetch URLs.
        let results = try await service.images(query: query)

        // Step 3: Find the ImageGeneration in your collection and update it with the URLs.
        if let index = generations.firstIndex(where: { $0.id == tempImageGeneration.id }) {
            let urlObjects = results.data.compactMap { urlResult -> URL? in
                guard let urlString = urlResult.url, let url = URL(string: urlString) else {
                    return nil
                }
                return url
            }
            generations[index].urls = urlObjects
            generations[index].isGenerating = false
        }
        print(results)
    }
    
    func addDummies() {
//        generations.append(ImageGeneration(prompt: "batman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v superman", imageModel: "dall-e-3", urls: [URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!, URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!]))
//        generations.append(ImageGeneration(isGenerating: false, prompt: "batman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v superman", imageModel: "dall-e-3", urls: [URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!]))
//        generations.append(ImageGeneration(prompt: "batman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v superman", imageModel: "dall-e-3", urls: [URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!, URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!]))
//        generations.append(ImageGeneration(isGenerating: true, prompt: "batman v superman", imageModel: "dall-e-3", urls: []))
    }
    
}
