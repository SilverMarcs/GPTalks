//
//  ImageObject.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/02/2024.
//

import Foundation
import OpenAI

struct ImageGeneration: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var isGenerating: Bool = false
    var prompt: String
    var imageModel: String
    var urls: [URL]
}
