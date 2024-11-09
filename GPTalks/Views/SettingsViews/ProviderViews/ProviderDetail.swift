//
//  ProviderDetail.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ProviderDetail: View {
    @Bindable var provider: Provider

    @State private var selectedTab: ProviderTab = .general

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
    
    private var picker: some View {
        Picker("Tabs", selection: $selectedTab) {
            ForEach(filteredTabs()) { tab in
                tab.label // Use Text to represent the label
                    .tag(tab)
                    #if os(macOS)
                    .labelStyle(.titleOnly)
                    #else
                    .labelStyle(.iconOnly)
                    #endif
            }
        }
        .popoverTip(ProviderRefreshTip())
        .pickerStyle(.segmented)
        .fixedSize()
    }

    private func filteredTabs() -> [ProviderTab] {
        switch provider.type {
        case .google, .anthropic, .vertex:
            // Only show chat tab
            return [.general, .chat]
        default:
            // Show all tabs
            return ProviderTab.allCases
        }
    }
}

#Preview {
    ProviderDetail(provider: .openAIProvider)
}
