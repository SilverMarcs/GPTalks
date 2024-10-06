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
    @State var showChatModelAdder = false
    @State var showImageModelAdder = false
    
    var body: some View {
        Group {
            switch selectedTab {
            case .general:
                ProviderGeneral(provider: provider, reorderProviders: reorderProviders)
            case .models:
                ModelListView<ChatModel>(provider: provider, models: $provider.chatModels)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                showChatModelAdder.toggle()
                            } label: {
                                Label("Add Model", systemImage: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $showChatModelAdder) {
                        AddModelSheet(chatModels: $provider.chatModels, imageModels: $provider.imageModels)
                    }
            case .image:
                ModelListView<ImageModel>(provider: provider, models: $provider.imageModels)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                showImageModelAdder.toggle()
                            } label: {
                                Label("Add Model", systemImage: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $showImageModelAdder) {
                        AddModelSheet(chatModels: $provider.chatModels, imageModels: $provider.imageModels)
                    }
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
            return ProviderDetailTab.allCases.filter { $0 != .image }
        }
    }

    private var picker: some View {
        Picker("Tabs", selection: $selectedTab) {
            ForEach(filteredTabs, id: \.self) { tab in
                Text(tab.rawValue.capitalized).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }
}


enum ProviderDetailTab: String, CaseIterable {
    case general
    case models
    case image
}

#Preview {
    ProviderDetail(provider: .openAIProvider) {}
}
