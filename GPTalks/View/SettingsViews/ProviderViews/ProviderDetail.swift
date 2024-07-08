//
//  ProviderDetail.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ProviderDetail: View {
    var provider: Provider

    @State private var selectedTab: ProviderDetailTab = .general

    var body: some View {
        VStack(spacing: 0) {
            Picker("Tabs", selection: $selectedTab) {
                ForEach(filteredTabs, id: \.self) { tab in
                    Text(tab.title)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .padding(.top)
            .frame(width: 240)

            switch selectedTab {
            case .general:
                ProviderGeneral(provider: provider)
                    .padding(.horizontal)
                    .padding(.bottom)
            case .models:
                ModelTable(provider: provider)
                    .padding()
            case .image:
                Text("Image")
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
    let provider = Provider.getDemoProvider()

    ProviderDetail(provider: provider)
}
