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
            Toggle(isOn: $config.googleSearch) {
                Text("Enabled for new chats")
            }

            IntegerStepper(value: $config.gSearchCount, label: "Search Result Count", step: 1, range: 1...10)
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
