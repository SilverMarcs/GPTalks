//
//  DefaultConfigView.swift
//  GPTalks
//
//  Created by LuoHuanyu on 2023/4/7.
//

import SwiftUI

struct DefaultConfigView: View {
    @ObservedObject var configuration: AppConfiguration = AppConfiguration.shared

    var body: some View {
        #if os(macOS)
            macOS
        #else
            iOS
        #endif
    }

    var macOS: some View {
        VStack(spacing: 20) {
            GroupBox(label: Text("Config")) {
                VStack {
                    LabeledPicker(title: "Markdown Enabled", width: widthValue, picker: markdownEnabler)
                    .padding(paddingValue)

                    Divider()
 
                    LabeledPicker(title: "Preferred Provider", width: widthValue, picker: preferredProvider)
                    .padding(paddingValue)
                }
            }

            GroupBox(label: Text("Parameters")) {
                LabeledPicker(title: "Context Length", width: widthValue, picker: contextPicker)
                .padding(paddingValue)

                Divider()

                HStack {
                    Text("Temperature")
                    Spacer()
                    tempSlider
                        .frame(width: widthValue)
                }
                .padding(paddingValue)

                Divider()

                HStack {
                    Text("System prompt")
                    Spacer()
                    systemPrompt
                        .textFieldStyle(.roundedBorder)
                        .frame(width: widthValue)
                }
                .padding(paddingValue)
            }
            Spacer()
        }
        .padding()
    }

    var iOS: some View {
        NavigationView {
            Form {
                Section("Default Settings") {
                    contextPicker
                    tempSlider
                }
                Section("System Prompt") {
                    systemPrompt
                        .lineLimit(4, reservesSpace: true)
                }
            }
        }
    }
    
    var markdownEnabler: some View {
        Picker("Markdown Enabled", selection: configuration.$isMarkdownEnabled) {
            Text("True").tag(true)
            Text("False").tag(false)
        }
    }
    
    var preferredProvider: some View {
        Picker("Preferred Provider", selection: configuration.$preferredChatService) {
            ForEach(Provider.availableProviders, id: \.self) { provider in
                Text(provider.name)
            }
        }
    }

    var contextPicker: some View {
        Picker("Context Length", selection: configuration.$contextLength) {
            ForEach(Array(stride(from: 2, through: 20, by: 2)), id: \.self) { number in
                Text("Last \(number) Messages")
                    .tag(number)
            }
        }
    }

    var tempSlider: some View {
        HStack(spacing: 15) {
            Slider(value: configuration.$temperature, in: 0 ... 2, step: 0.1) {
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("2")
            }
            Text(String(format: "%.2f", configuration.temperature))
        }
    }

    var systemPrompt: some View {
        TextField("Enter a system prompt", text: configuration.$systemPrompt, axis: .vertical)
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
            300
        #else
            180
        #endif
    }
}
