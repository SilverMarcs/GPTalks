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
                HStack {
                    Text("Temperature")

                    Slider(value: $config.temperature, in: 0...2, step: 0.1) {
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("2")
                    }
                }

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
