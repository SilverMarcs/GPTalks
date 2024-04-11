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
            model = AppConfiguration.shared.preferredImageService.preferredImageModel
            quality = .hd
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

        withAnimation {
            generations.append(tempImageGeneration)
        }

        if let index = generations.firstIndex(where: { $0.id == tempImageGeneration.id }) {
            await generations[index].send(query: query, configuration: configuration)
        }

    }

    func addDummies() {

    }
}
