//
//  ImageSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/02/2024.
//

import OpenAI
import SwiftUI

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
            model = .dalle3
            quality = .standard
        }
    }

    var id = UUID()
    var configuration = Configuration()
    var input: String = ""
    var generations: [ImageGeneration] = []
    var errorDesc: String = ""

//    var streamingTask: Task<Void, Error>?

    @MainActor
    func send() async {
        errorDesc = ""

        let query = ImagesQuery(prompt: input, model: configuration.model.id, n: configuration.count, quality: configuration.quality, size: ._1024)

        
        let tempImageGeneration = ImageGeneration(prompt: input, imageModel: configuration.model == .customImage ? configuration.model.id : configuration.model.name)

        generations.append(tempImageGeneration)

        if let index = generations.firstIndex(where: { $0.id == tempImageGeneration.id }) {
            await generations[index].send(query: query, configuration: configuration)
        }

    }

    @MainActor
    func sendHelper(query: ImagesQuery) async throws {
        let tempImageGeneration = ImageGeneration(prompt: input, imageModel: configuration.model.name)

        generations.append(tempImageGeneration)

        if let index = generations.firstIndex(where: { $0.id == tempImageGeneration.id }) {
            await generations[index].send(query: query, configuration: configuration)
        }
    }

    func addDummies() {
//        generations.append(ImageGeneration(prompt: "batman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v superman", imageModel: "dall-e-3", urls: [URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!, URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!]))
//        generations.append(ImageGeneration(prompt: "batman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v superman", imageModel: "dall-e-3", urls: [URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!]))
//        generations.append(ImageGeneration(prompt: "batman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v supermanbatman v superman", imageModel: "dall-e-3", urls: [URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!, URL(string: "https://u128907-a9aa-d8229a13.westc.gpuhub.com:8443/view?filename=ComfyUI_101194_.png&subfolder=&type=output")!]))
//        generations.append(ImageGeneration(prompt: "batman v superman", imageModel: "dall-e-3", urls: []))
    }
}
