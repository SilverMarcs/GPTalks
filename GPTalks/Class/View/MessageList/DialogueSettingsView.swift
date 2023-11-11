//
//  DialogueSettingsView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/26.
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
        VStack {
            FormContent
        }
        .padding()
        .frame(width: 300, height: 250)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.focusedField = nil
            }
        }
        #else
        Form {
            FormContent
        }
        .navigationTitle("Settings")
        #endif
    }
    var FormContent: some View {
        Group {
            Section {
                HStack {
                    Text("Provider")
                        .fixedSize()
                    Spacer()
                    Text(configuration.service.name)
                        .fixedSize()
                        .frame(width: 170)
                }
                
                HStack {
                    Text("Title")
                        .fixedSize()
                    Spacer()
                    TextField("Chat title", text: $title)
                        .focused($focusedField, equals: .title)
//                        .textFieldStyle(.roundedBorder)
                        .frame(width: 170)
//                        .labelsHidden()
                }
                
                HStack {
                    Text("Model")
                        .fixedSize()
                    Spacer()
                    Picker("Model", selection: $configuration.model) {
                        ForEach(configuration.service.models, id: \.self) { model in
                            Text(model.name)
                                .tag(model.id)
                        }
                    }
                    .frame(width: 170)
                    .labelsHidden()
                }
                
                HStack {
                    Text("Context")
                        .fixedSize()
                    Spacer()
                    Picker("Model", selection: $configuration.contextLength) {
                        ForEach(Array(1...10).reversed() + [30], id: \.self) { number in
                            Text(number == 30 ? "Unlimited Messages" : "Last \(number) Messages")
                                .tag(number)
                        }
                    }
                    .frame(width: 170)
                    .labelsHidden()
                }
                
                VStack {
                    Stepper(value: $configuration.temperature, in: 0...2, step: 0.1) {
                        HStack {
                            Text("Temperature")
                            Spacer()
                            Text(String(format: "%.1f", configuration.temperature))
                                .padding(.horizontal)
                                .height(32)
                                .width(60)
                                .background(Color.secondarySystemFill)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            Section {
                TextField("Enter a system prompt", text: $configuration.systemPrompt, axis: .vertical)
                    .focused($focusedField, equals: .systemPrompt)
                    .lineLimit(4, reservesSpace: true)
            }
        }
    }
}
