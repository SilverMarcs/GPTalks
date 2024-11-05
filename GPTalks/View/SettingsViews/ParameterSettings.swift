//
//  ParameterSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

struct ParameterSettings: View {
    @ObservedObject var config = ChatConfigDefaults.shared
    @State var expandAdvanced: Bool = true

    var body: some View {
        Form {
            Section("Basic") {
                Toggle("Stream", isOn: $config.stream)
                TemperatureSlider(temperature: $config.temperature)
                MaxTokensPicker(value: $config.maxTokens)
            }

            Section("System Prompt") {
                sysPrompt
            }
            
            Section("Advanced", isExpanded: $expandAdvanced) {
                TopPSlider(topP: $config.topP)
                FrequencyPenaltySlider(penalty: $config.frequencyPenalty)
                PresencePenaltySlider(penalty: $config.presencePenalty)
            }
        }
        .navigationTitle("Parameters")
        .toolbarTitleDisplayMode(.inline)
        .formStyle(.grouped)
    }
    
    var sysPrompt: some View {
        TextField("System Prompt", text: $config.systemPrompt, axis: .vertical)
            .lineLimit(lineLimit, reservesSpace: true)
            .labelsHidden()
    }
    
    var lineLimit: Int {
        #if os(macOS)
        8
        #else
        5
        #endif
    }
}

#Preview {
    ParameterSettings()
}
