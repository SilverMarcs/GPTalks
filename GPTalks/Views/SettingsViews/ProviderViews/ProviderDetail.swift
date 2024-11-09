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
                ModelList(provider: provider, type: .chat)
            case .image:
                ModelList(provider: provider, type: .image)
            case .stt:
                ModelList(provider: provider, type: .stt)
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
        .onChange(of: selectedTab) {
            if selectedTab == .chat {
                ProviderRefreshTip().invalidate(reason: .actionPerformed)
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
