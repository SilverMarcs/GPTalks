//
//  GoogleSearchSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

struct GoogleSearchSettings: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    
    var body: some View {
        Section("General") {
            Toggle("Enabled for new chats", isOn: $config.googleSearch)
            Stepper(
                "Search Result Count",
                value: Binding<Double>(
                    get: { Double(config.gSearchCount) },
                    set: { config.gSearchCount = Int($0) }
                ),
                in: 1...10,
                step: 1,
                format: .number
            )
        }
        
        Section("Secrets") {
            TextField("Google Search API Key", text: $config.googleApiKey)
            TextField("Google Search Engine ID", text: $config.googleSearchEngineId)
        }
    }
}

#Preview {
    GoogleSearchSettings()
}
