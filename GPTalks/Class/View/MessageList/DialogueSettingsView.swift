//
//  DialogueSettingsView.swift
//  ChatGPT
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
            VStack {
                FormContent
            }
            .padding()
            .frame(width: 300, height: 220)
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
            VStack {
                HStack {
                    Text("Provider")
                        .fixedSize()
                    Spacer()
                    Text(configuration.provider.name)
                        .frame(width: 170)
                }

                #if os(iOS)
                    HStack {
                        Text("Title")
                            .fixedSize()
                        Spacer()
                        TextField("Chat title", text: $title)
                            .focused($focusedField, equals: .title)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: width)
                    }
                #endif

                HStack {
                    Text("Model")
                        .fixedSize()
                    Spacer()
                    Picker("", selection: $configuration.model) {
                        ForEach(configuration.provider.models, id: \.self) { model in
                            Text(model.name)
                                .tag(model.id)
                        }
                    }
                    .frame(width: width)
                }

                HStack {
                    Text("Context")
                        .fixedSize()
                    Spacer()
                    Picker("", selection: $configuration.contextLength) {
                        ForEach(Array(stride(from: 2, through: 20, by: 2)), id: \.self) { number in
                            Text("Last \(number) Messages")
                                .tag(number)
                        }
                    }
                    .frame(width: width)
                }

                VStack {
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
                Section {
                    TextField("Enter a system prompt", text: $configuration.systemPrompt, axis: .vertical)
                        .focused($focusedField, equals: .systemPrompt)
                        .lineLimit(4, reservesSpace: true)
                }
            }
        }
    }

    private var width: CGFloat {
        #if os(iOS)
            return 170
        #else
            return 150
        #endif
    }
}
