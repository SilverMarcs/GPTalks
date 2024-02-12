//
//  DialogueSettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI

struct DialogueSettingsView: View {
    @Binding var configuration: DialogueSession.Configuration
    @Binding var title: String

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
                LabeledPicker(title: "Provider", picker: providerPicker)
                    .onChange(of: configuration.provider) {
                        configuration.model = configuration.provider.preferredModel
                    }
                
                LabeledPicker(title: "Model", picker: modelPicker)

                LabeledPicker(title: "Context", picker: contextPicker)
    
                tempStepper
                
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

#if !os(macOS)
    var iOS: some View {
        NavigationView {
            Form {
                Section("Parameters") {
                    providerPicker
                        .onChange(of: configuration.provider) {
                            configuration.model = configuration.provider.preferredModel
                        }
                    
                    modelPicker

                    contextPicker
                    
                    tempStepper
                }
                
                Section("System Prompt") {
                    systemPrompt
                }
            }
            .navigationTitle($title)
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
    
    var providerPicker: some View {
        Picker("Provider", selection: $configuration.provider) {
            ForEach(Provider.availableProviders, id: \.self) { provider in
                Text(provider.name)
                    .tag(provider.id)
            }
        }
    }
    
    var modelPicker: some View {
        Picker("Model", selection: $configuration.model) {
            ForEach(configuration.provider.models, id: \.self) { model in
                Text(model.name)
                    .tag(model.id)
            }
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
