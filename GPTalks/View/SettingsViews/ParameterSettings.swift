//
//  ParameterSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

struct ParameterSettings: View {
    @ObservedObject var config = AppConfig.shared
    #if os(macOS)
    @State var expandAdvanced: Bool = true
    #else
    @State var expandAdvanced: Bool = false
    #endif
    

    var body: some View {
        Form {
            Section("Basic") {
                TemperatureSlider(temperature: $config.temperature)
                MaxTokensPicker(value: $config.maxTokens)
            }

            Section("System Prompt") {
                TextEditor(text: $config.systemPrompt)
                    .font(.body)
                    .frame(height: 80)
                    .scrollContentBackground(.hidden)
            }
            
//            #if os(macOS)
            Section("Advanced", isExpanded: $expandAdvanced) {
                TopPSlider(topP: $config.topP)
                FrequencyPenaltySlider(penalty: $config.frequencyPenalty)
                PresencePenaltySlider(penalty: $config.presencePenalty)
            }
//            #endif
        }
        .navigationTitle("Parameters")
        .toolbarTitleDisplayMode(.inline)
        .formStyle(.grouped)
    }
}

#Preview {
    ParameterSettings()
}
