//
//  ProviderDetail.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ProviderDetail: View {
    @Bindable var provider: Provider

    @State private var selectedTab: ProviderDetailTab = .general

    var body: some View {
        Group {
            switch selectedTab {
            case .general:
                ProviderGeneral(provider: provider)
            case .chat:
                ModelList(provider: provider, models: $provider.chatModels)
            case .image:
                ModelList(provider: provider, models: $provider.imageModels)
            case .stt:
                ModelList(provider: provider, models: $provider.sttModels)
            }
        }
        .scrollContentBackground(.visible)
        .navigationTitle(provider.name)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                picker
            }
        }
    }

//    private var filteredTabs: [ProviderDetailTab] {
//        (provider.type == .vertex || provider.type == .google || provider.type == .anthropic
//        ? [.general, .chat]
//        : [.general, .chat, .image, .stt])
//    }

    private var picker: some View {
        Picker("Tabs", selection: $selectedTab) {
            ForEach(ProviderDetailTab.allCases, id: \.self) { tab in
                tab.name.tag(tab)
                    .labelStyle(.iconOnly)
            }
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }
}

enum ProviderDetailTab: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case general
    case chat
    case image
    case stt

    var name: some View {
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

#Preview {
    ProviderDetail(provider: .openAIProvider)
}
