//
//  ProviderDetail.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

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
            case .models:
                ModelListView<ChatModel>(provider: provider, models: $provider.chatModels)
            case .image:
                ModelListView<ImageModel>(provider: provider, models: $provider.imageModels)
            case .tts:
                ModelListView<TTSModel>(provider: provider, models: $provider.ttsModels)
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
    
    private var filteredTabs: [ProviderDetailTab] {
        if provider.type == .openai {
            return ProviderDetailTab.allCases
        } else {
            return ProviderDetailTab.allCases.filter { $0 != .image || $0 != .tts }
        }
    }

    private var picker: some View {
        Picker("Tabs", selection: $selectedTab) {
            ForEach(filteredTabs) { tab in
                Text(tab.name).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }
}


enum ProviderDetailTab: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case general
    case models
    case image
    case tts
    
    var name: String {
        switch self {
        case .general:
            return "General"
        case .models:
            return "Chat"
        case .image:
            return "Image"
        case .tts:
            return "TTS"
        }
    }
}

#Preview {
    ProviderDetail(provider: .openAIProvider) {}
}
