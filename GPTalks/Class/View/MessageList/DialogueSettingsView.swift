//
//  DialogueSettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI

struct DialogueSettingsView: View {
    @Binding var configuration: DialogueSession.Configuration
    var provider: Provider

    @FocusState private var focusedField: FocusedField?

    @Environment(\.dismiss) var dismiss

    enum FocusedField: Hashable {
        case systemPrompt
        case title
    }

    var body: some View {
        #if os(macOS)
            macOS
        #else
            iOS
        #endif
    }

    var macOS: some View {
            VStack {
                HStack {
                    Text("Model")
                        .fixedSize()
                    Spacer()
//                    Picker("", selection: $configuration.model) {
//                        ForEach(configuration.provider.models, id: \.self) { model in
//                            Text(model.name)
//                                .tag(model.id)
//                        }
//                    }
                    modelPicker
                        .labelsHidden()
                        .frame(width: width)
                }
                
                if provider == .gpt4free {
                    HStack {
                        Text("Provider")
                            .fixedSize()
                        Spacer()
//                        Picker("", selection: $configuration.model) {
//                            ForEach(configuration.provider.models, id: \.self) { model in
//                                Text(model.name)
//                                    .tag(model.id)
//                            }
//                        }
                        providerPicker
                            .labelsHidden()
                            .frame(width: width)
                    }
                    
                    HStack {
                        Text("Ignore Web")
                            .fixedSize()
                        Spacer()
                        ignoreWeb
                            .labelsHidden()
                            .frame(width: width)
                    }
                    
                }

                HStack {
                    Text("Context")
                        .fixedSize()
                    Spacer()
//                    Picker("", selection: $configuration.contextLength) {
//                        ForEach(Array(stride(from: 2, through: 20, by: 2)), id: \.self) { number in
//                            Text("Last \(number) Messages")
//                                .tag(number)
//                        }
//                    }
                    contextPicker
                        .labelsHidden()
                        .frame(width: width)
                }

//                Stepper(value: $configuration.temperature, in: 0 ... 2, step: 0.1) {
//                    HStack {
//                        Text("Temperature")
//                        Spacer()
//                        Text(String(format: "%.1f", configuration.temperature))
//                            .padding(.horizontal)
//                            .cornerRadius(6)
//                    }
//                }
                
                tempStepper
                
//                TextField("Enter a system prompt", text: $configuration.systemPrompt, axis: .vertical)
//                    .focused($focusedField, equals: .systemPrompt)
//                    .lineLimit(4, reservesSpace: true)
                systemPrompt
        
            }
            .padding()
            .frame(width: 300, height: 230)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.focusedField = nil
                }
            }
    }

    #if os(iOS)
    var iOS: some View {
        NavigationView {
            Form {
                Section("Parameters") {
                    modelPicker
                    providerPicker
                    ignoreWeb
                    contextPicker
                    tempStepper
                }
                Section("System Prompt") {
                    systemPrompt
                }
            }
            .navigationTitle(provider.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
    #endif
    
    var modelPicker: some View {
        Picker("Model", selection: $configuration.model) {
            ForEach(configuration.provider.models, id: \.self) { model in
                Text(model.name)
                    .tag(model.id)
            }
        }
    }
    
    var providerPicker: some View {
        Picker("Provider", selection: $configuration.gpt4freeProvider) {
            ForEach(GPT4FreeProvider.allCases, id: \.self) { provider in
                Text(provider.name)
                    .tag(provider.rawValue)
            }
        }
    }
    
    var ignoreWeb: some View {
        Picker("Ignore Web", selection: $configuration.ignoreWeb) {
            Text("True").tag("True")
            Text("False").tag("False")
        }
    }
    
    var contextPicker: some View {
        Picker("Context", selection: $configuration.contextLength) {
            ForEach(Array(stride(from: 2, through: 20, by: 2)), id: \.self) { number in
                Text("Last \(number) Messages")
                    .tag(number)
            }
        }
    }
    
    var tempStepper: some View {
        Stepper(value: $configuration.temperature, in: 0 ... 2, step: 0.1) {
            HStack {
                Text("Temperature")
                Spacer()
                Text(String(format: "%.1f", configuration.temperature))
                    .padding(.horizontal)
                    .cornerRadius(6)
            }
        }
    }
    
    var systemPrompt: some View {
        TextField("Enter a system prompt", text: $configuration.systemPrompt, axis: .vertical)
            .focused($focusedField, equals: .systemPrompt)
            .lineLimit(4, reservesSpace: true)
    }
    
    private var width: CGFloat {
        #if os(iOS)
            return 190
        #else
            return 150
        #endif
    }
}
