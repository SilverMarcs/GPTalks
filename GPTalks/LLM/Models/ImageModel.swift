//
//  ImageModel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/10/2024.
//

import Foundation

struct ImageModel: Hashable, Identifiable, Codable {
    var id: UUID = UUID()
    var code: String
    var name: String
    
    init(code: String, name: String) {
        self.code = code
        self.name = name
    }
    
    static func getOpenImageModels() -> [ImageModel] {
        return [
            ImageModel(code: "dall-e-2", name: "DALL-E-2"),
            ImageModel(code: "dall-e-3", name: "DALL-E-3"),
        ]
    }
}
