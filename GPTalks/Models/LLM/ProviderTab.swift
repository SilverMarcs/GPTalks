//
//  ProviderTab.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/11/2024.
//

import SwiftUI

enum ProviderTab: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case general
    case chat
    case image
    case stt

    var label: some View {
        switch self {
        case .general:
            Label("General", systemImage: "info.circle")
        case .chat:
            Label("Chat", systemImage: "quote.bubble")
        case .image:
            Label("Image", systemImage: "photo")
        case .stt:
            Label("STT", systemImage: "waveform")
        }
    }
}
