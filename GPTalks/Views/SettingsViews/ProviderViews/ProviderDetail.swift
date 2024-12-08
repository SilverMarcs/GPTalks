//
//  ProviderDetail.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ProviderDetail: View {
    @Bindable var provider: Provider
    
    @State private var selectedTab: ModelType? = nil

    var body: some View {
        content
            .scrollContentBackground(.visible)
            .navigationTitle(provider.name)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    picker
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        if selectedTab == nil {
            ProviderGeneral(provider: provider)
        } else if let modelType = selectedTab {
            ModelList(provider: provider, type: modelType)
        }
    }

    private var picker: some View {
        Picker("Tabs", selection: $selectedTab) {
            Label("General", systemImage: "info.circle")
                .tag(ModelType?.none)
            ForEach(provider.type.availableModelTypes, id: \.self) { modelType in
                Label(modelType.name, systemImage: modelType.icon)
                    .tag(modelType)
            }
        }
        #if os(macOS)
        .labelStyle(.titleOnly)
        #else
        .labelStyle(.iconOnly)
        #endif
        .onChange(of: selectedTab) {
            if selectedTab == .chat {
                ProviderRefreshTip().invalidate(reason: .actionPerformed)
            }
        }
        .popoverTip(ProviderRefreshTip())
        .pickerStyle(.segmented)
        .fixedSize()
    }
}

#Preview {
    ProviderDetail(provider: .openAIProvider)
}
