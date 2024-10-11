//
//  ModelTypeOption.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/10/2024.
//

import Foundation

enum ModelTypeOption: String, CaseIterable {
    case chat
    case image
    case stt
    
    var icon: String {
        switch self {
        case .chat:
            return "quote.bubble"
        case .image:
            return "photo"
        case .stt:
            return "waveform"
        }
    }
}
