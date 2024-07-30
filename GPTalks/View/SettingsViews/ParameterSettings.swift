//
//  ParameterSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

struct ParameterSettings: View {
    @ObservedObject var config = SessionConfigDefaults.shared
    @State var expandAdvanced: Bool = false

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
            
            #if os(macOS)
            Section("Advanced", isExpanded: $expandAdvanced) {
                TopPSlider(topP: $config.topP)
                FrequencyPenaltySlider(penalty: $config.frequencyPenalty)
                PresencePenaltySlider(penalty: $config.presencePenalty)
            }
            #endif
        }
        .navigationTitle("Parameters")
        .toolbarTitleDisplayMode(.inline)
        .formStyle(.grouped)
    }
    
    var sysPrompt: some View {
        #if os(macOS)
        TextEditor(text: $config.systemPrompt)
            .font(.body)
            .frame(height: 80)
            .scrollContentBackground(.hidden)
        #else
        TextField("System Prompt", text: $config.systemPrompt, axis: .vertical)
            .lineLimit(4, reservesSpace: true)
        #endif
    }
}

#Preview {
    ParameterSettings()
}
