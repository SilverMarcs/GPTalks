//
//  ProviderDetail.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ProviderDetail: View {
    @Bindable var provider: Provider
    var reorderProviders: () -> Void
    
    @State private var selectedTab: ProviderDetailTab = .general
    
    var body: some View {
        Group {
            switch selectedTab {
            case .general:
                ProviderGeneral(provider: provider, reorderProviders: reorderProviders)
            case .chat:
                ModelList<ChatModel>(provider: provider, models: $provider.chatModels)
            case .image:
                ModelList<ImageModel>(provider: provider, models: $provider.imageModels)
            case .tts:
                ModelList<STTModel>(provider: provider, models: $provider.sttModels)
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
//        provider.type == .openai ? ProviderDetailTab.allCases : ProviderDetailTab.allCases.filter { $0 != .image && $0 != .tts }
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
    case tts
    
    var name: some View {
        switch self {
        case .general:
            Label("General", systemImage: "info.circle")
        case .chat:
            Label("Chat", systemImage: "quote.bubble")
        case .image:
            Label("Image", systemImage: "photo")
        case .tts:
            Label("TTS", systemImage: "waveform")
        }
    }
}

#Preview {
    ProviderDetail(provider: .openAIProvider) {}
}
