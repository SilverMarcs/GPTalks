//
//  AppearanceSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI
import SwiftData

struct AppearanceSettings: View {
    @Query(sort: \Provider.date, order: .reverse) var providers: [Provider]
    @ObservedObject var selectionManager = ProviderManager.shared
    
    var body: some View {
        Form {
            Section(header: Text("Default Provider")) {
                Picker("Select Default Provider", selection: $selectionManager.defaultProvider) {
                    ForEach(providers, id: \.id) { provider in
                        Text(provider.name).tag(provider.id.uuidString)
                    }
                }
            }
        }
        .onAppear {
            if let defaultProvider = selectionManager.getDefault(providers: providers) {
                selectionManager.defaultProvider = defaultProvider.id.uuidString
            }
        }
    }
}

#Preview {
    AppearanceSettings()
}
