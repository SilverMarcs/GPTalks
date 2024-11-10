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
            Text("General").tag(ModelType?.none)
            ForEach(provider.type.availableModelTypes, id: \.self) { modelType in
                Text(modelType.rawValue.capitalized).tag(Optional(modelType))
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
}

#Preview {
    ProviderDetail(provider: .openAIProvider)
}
