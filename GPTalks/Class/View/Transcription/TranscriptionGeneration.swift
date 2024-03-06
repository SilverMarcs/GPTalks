//
//  TranscriptionGeneration.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/03/2024.
//

import Foundation
import OpenAI

@Observable class TranscriptionGeneration: Identifiable, Hashable, Equatable {
    static func == (lhs: TranscriptionGeneration, rhs: TranscriptionGeneration) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: UUID = UUID()
    var errorDesc: String = ""
    var isGenerating: Bool = true
    var audioData: Data
    var model: String
    var transcription: String = ""
    
    init(audioData: Data, audioModel: String) {
        self.audioData = audioData
        self.model = audioModel
    }
    
    //    var streamingTask: Task<Void, Error>?
    
    func send(configuration: TranscriptionSession.Configuration) async {
        let service: OpenAI = OpenAI(configuration: configuration.provider.config)
        
        let query = AudioTranscriptionQuery(file: audioData, fileType: .mp3, model: .whisper_1)
        
        do {

            let result = try await service.audioTranscriptions(query: query)
            
            transcription = result.text
            
            print(result.text)
        } catch {
            // Handle errors (e.g., file not found, insufficient permissions, etc.)
            print("Error reading file: \(error)")
        }
    }
}
