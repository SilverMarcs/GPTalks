//
//  TranscriptionModel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/10/2024.
//

import Foundation

struct TTSModel: Hashable, Identifiable, Codable, ModelType {
    var id: UUID = UUID()
    var code: String
    var name: String

    init(code: String, name: String) {
        self.code = code
        self.name = name
    }
    
    static func getOpenAITTSModels() -> [TTSModel] {
        return [
            TTSModel(code: "whisper-1", name: "Whisper-1"),
        ]
    }
}
