//
//  ImageSession.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/02/2024.
//

import SwiftUI

//@Observable class ImageSession: Identifiable, Equatable, Hashable {
//    
//    static func == (lhs: ImageSession, rhs: ImageSession) -> Bool {
//        lhs.id == rhs.id
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    
//    struct Configuration: Codable {
//        var count: Int
//        var provider: Provider
//        var model: Model
//        var quality: String
//
//        init() {
//            count = 1
//            provider = AppConfiguration.shared.preferredImageService
//            model = AppConfiguration.shared.defaultImageModel
//            quality = ""
//        }
//    }
//
//    var id = UUID()
//    var input: String = ""
//    var imageGenerations: [ImageGeneration] = []
//    var errorDesc: String = ""
//    
//    var streamingTask: Task<Void, Error>?
//    
//}
