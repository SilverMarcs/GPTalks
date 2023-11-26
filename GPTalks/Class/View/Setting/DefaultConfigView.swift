//
//  PAISettingsView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/4/7.
//

import SwiftUI

struct DefaultConfigView: View {
    @ObservedObject var configuration: AppConfiguration = AppConfiguration.shared

    var body: some View {
        #if os(macOS)
            ScrollView {
                GroupBox(label: Text("Default Settings").font(.headline).padding(.bottom, 5)) {
                    macOS
                }
                .padding()
            }
        #else
            iOS
        #endif
    }

    var macOS: some View {
        VStack {
            HStack {
                Text("Context Length")
                Spacer()
                contextPicker
                .labelsHidden()
                .frame(width: widthValue)
            }
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
