//
//  ProviderDetail.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

import SwiftUI

struct ProviderDetail: View {
    var provider: Provider
    @State private var selectedTab: ProviderDetailTab = .general
    
    var body: some View {
        VStack(spacing: 0) {
#if os(macOS)
            picker
                .padding(.top)
#endif
            
            switch selectedTab {
            case .general:
                ProviderGeneral(provider: provider)
            case .models:
                #if os(macOS)
                ModelTable(provider: provider)
                #else
                ModelList(provider: provider)
                #endif
            case .image:
                VStack {
                    Text("Not implemented yet.")
                    Spacer()
                }
            }
        }
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .principal) {
                picker
            }
        }
#endif
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
                Text(tab.title).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .fixedSize()
#if os(macOS)
        .frame(width: 240)
#endif
    }

}


enum ProviderDetailTab: CaseIterable {
    case general
    case models
    case image

    var title: String {
        switch self {
        case .general:
            "General"
        case .models:
            "Models"
        case .image:
            "Image"
        }
    }
}

#Preview {
    let provider = Provider.factory(type: .openai)

    ProviderDetail(provider: provider)
}
