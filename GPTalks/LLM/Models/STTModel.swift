//
//  STTModel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/10/2024.
//

import Foundation

struct STTModel: Hashable, Identifiable, Codable, ModelType {
    var id: UUID = UUID()
    var code: String
    var name: String

    init(code: String, name: String) {
        self.code = code
        self.name = name
    }
    
    static func getOpenAITTSModels() -> [STTModel] {
        return [
            STTModel(code: "whisper-1", name: "Whisper-1"),
        ]
    }
}
