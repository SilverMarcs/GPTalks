//
//  AppearanceSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/9/24.
//

import SwiftUI
import SwiftData

struct AppearanceSettings: View {
    @Environment(\.modelContext) var modelContext
    @ObservedObject var config = AppConfig.shared
    
    @State var session: Chat?

    var body: some View {
        Form {
            Section("Font Size") {
                HStack {
                    Button("Reset") {
                        config.resetFontSize()
                    }
                    Slider(value: $config.fontSize, in: 8...25, step: 1) {
                        Text("")
                    } minimumValueLabel: {
                        Text("")
                            .monospacedDigit()
                    } maximumValueLabel: {
                        Text(String(config.fontSize))
                            .monospacedDigit()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Appearance")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    AppearanceSettings()
}

