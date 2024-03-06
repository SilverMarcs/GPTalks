//
//  TranscriptionSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/03/2024.
//

import Foundation
import SwiftUI
import OpenAI

@Observable class TranscriptionSession: Identifiable, Equatable, Hashable {
    static func == (lhs: TranscriptionSession, rhs: TranscriptionSession) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    struct Configuration: Codable {
        var provider: Provider
        var model: Model

        init() {
            provider = .naga
            model = AppConfiguration.shared.preferredImageService.preferredImageModel
        }
    }
    
    var id = UUID()
    var input: URL = URL(fileURLWithPath: "")
    var configuration: Configuration = Configuration()
    var generations: [TranscriptionGeneration] = []
    
    @MainActor
    func send() async {

        
        do {
        
            let audioData = try Data(contentsOf: input)
        
            let tempGeneration = TranscriptionGeneration(audioData: audioData, audioModel: configuration.model.name)
//            let query = AudioTranscriptionQuery(file: audioData, fileType: .mp3, model: .whisper_1)
            
            withAnimation {
                generations.append(tempGeneration)
            }

            if let index = generations.firstIndex(where: { $0.id == tempGeneration.id }) {
                await generations[index].send(configuration: configuration)
            }
        } catch {
            print("Error reading file: \(error)")
        }
    }
}
