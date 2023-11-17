//
//  PAISettingsView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/4/7.
//

import SwiftUI

struct ServiceSettingsView: View {
    @Binding var model: Model
    @Binding var temperature: Double
    @Binding var contextLength: Int
    @Binding var systemPrompt: String
    @Binding var apiKey: String
    var models: [Model]
    var navigationTitle: String

    @State private var showAPIKey = false

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
                .navigationTitle(navigationTitle)
            }
        #endif
    }

    var settings: some View {
        VStack {
            HStack {
                Text("Model")
                Spacer()
                Picker("", selection: $model) {
                    ForEach(models, id: \.self) { model in
                        Text(model.name)
                            .tag(model.id)
                    }
                }
                .labelsHidden()
                .frame(width: widthValue)
            }
            .padding(paddingValue)

            Divider()

            HStack {
                Text("Context Length")
                Spacer()
                Picker("", selection: $contextLength) {
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
                    Slider(value: $temperature, in: 0 ... 2, step: 0.1) {
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("2")
                    }
                    Text(String(format: "%.2f", temperature))
                }
                .frame(width: widthValue)
            }
            .padding(paddingValue)

            Divider()

            HStack {
                Text("System prompt")
                Spacer()
                TextField("System Prompt", text: $systemPrompt)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: widthValue)
            }
            .padding(paddingValue)

            Divider()

            HStack {
                Text("API Key")
                Spacer()

                HStack {
                    if showAPIKey {
                        TextField("", text: $apiKey)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        SecureField("", text: $apiKey)
                            .textFieldStyle(.roundedBorder)
                    }
                    Button {
                        showAPIKey.toggle()
                    } label: {
                        if showAPIKey {
                            Image(systemName: "eye.slash")
                        } else {
                            Image(systemName: "eye")
                        }
                    }
                    .buttonStyle(.borderless)
                }
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
