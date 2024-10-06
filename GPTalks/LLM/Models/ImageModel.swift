//
//  ImageModel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/10/2024.
//

import SwiftData
import Foundation

@Model
final class ImageModel: Hashable, Identifiable {
    var id: UUID = UUID()
    var code: String
    var name: String
    var lastTestResult: Bool?

    init(code: String, name: String, lastTestResult: Bool? = nil) {
        self.code = code
        self.name = name
        self.lastTestResult = lastTestResult
    }
    
    static func getOpenImageModels() -> [ImageModel] {
        return [
            ImageModel(code: "dall-e-2", name: "DALL-E-2"),
            ImageModel(code: "dall-e-3", name: "DALL-E-3"),
        ]
    }
}
