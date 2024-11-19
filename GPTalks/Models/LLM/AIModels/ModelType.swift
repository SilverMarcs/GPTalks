//
//  ModelType.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/10/2024.
//

import Foundation

enum ModelType: String, CaseIterable, Codable {
    case chat
    case image
    case stt
    
    var name: String {
        switch self {
        case .chat:
            "Chat"
        case .image:
            "Image"
        case .stt:
            "STT"
        }
    }
    
    var icon: String {
        switch self {
        case .chat:
            "quote.bubble"
        case .image:
            "photo"
        case .stt:
            "waveform"
        }
    }
}
