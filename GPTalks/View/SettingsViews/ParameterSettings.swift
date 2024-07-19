//
//  ParameterSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

struct ParameterSettings: View {
    @ObservedObject var config = AppConfig.shared

    var body: some View {
        Form {
            Section("Parameters") {
                TemperatureSlider(temperature: $config.temperature)
                TopPSlider(topP: $config.topP)
                FrequencyPenaltySlider(penalty: $config.frequencyPenalty)
                PresencePenaltySlider(penalty: $config.presencePenalty)
                MaxTokensPicker(value: $config.maxTokens)
            }

            Section("System Prompt") {
                TextEditor(text: $config.systemPrompt)
                    .font(.body)
                    .frame(height: 100)
                    .scrollContentBackground(.hidden)
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    ParameterSettings()
}
