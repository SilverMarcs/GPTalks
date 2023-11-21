//
//  PAISettingsView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/4/7.
//

import SwiftUI

struct DefaultConfigView: View {
//    @Binding var model: Model
//    @Binding var temperature: Double
//    @Binding var contextLength: Int
//    @Binding var systemPrompt: String
//    @Binding var apiKey: String
//    var models: [Model]
//    var navigationTitle: String
    
    @ObservedObject var configuration: AppConfiguration = AppConfiguration.shared

//    @State private var showAPIKey = false

    var body: some View {
        #if os(macOS)
            ScrollView {
                GroupBox(label: Text("Default Settings").font(.headline).padding(.bottom, 5)) {
                    settings
                }
                .padding()
            }
        #else
            Form {
                Section("Default Settings") {
                    settings
                }
            }
        #endif
    }

    var settings: some View {
        VStack {
            HStack {
                Text("Context Length")
                Spacer()
                Picker("", selection: configuration.$contextLength) {
                    ForEach(Array(1 ... 10).reversed() + [30], id: \.self) { number in
                        Text(number == 30 ? "Unlimited Messages" : "Last \(number) Messages")
                            .tag(number)
                    }
                }
                .labelsHidden()
                .frame(width: widthValue)
            }
            .padding(paddingValue)

            Divider()

            HStack {
                Text("Temperature")
                Spacer()
                HStack {
                    Slider(value: configuration.$temperature, in: 0 ... 2, step: 0.1) {
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("2")
                    }
                    Text(String(format: "%.2f", configuration.temperature))
                }
                .frame(width: widthValue)
            }
            .padding(paddingValue)

            Divider()

            HStack {
                Text("System prompt")
                Spacer()
                TextField("System Prompt", text: configuration.$systemPrompt)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: widthValue)
            }
            .padding(paddingValue)
        }
    }

    var paddingValue: CGFloat {
        #if os(macOS)
            10
        #else
            0
        #endif
    }

    var widthValue: CGFloat {
        #if os(macOS)
            240
        #else
            180
        #endif
    }
}
