//
//  ProviderGeneral.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI
import SwiftData

struct ProviderGeneral: View {
    @Bindable var provider: Provider
    
    @State private var showKey: Bool = false
    @State private var showPopover: Bool = false
    @State private var color = Color(.sRGB, red: 1, green: 1, blue: 1)
    
    @Query var providerDefaults: [ProviderDefaults]

    var body: some View {
        Form {
            Section {
                header
            }
            
            Section {
                HStack {
                    TextField("Host URL", text: $provider.host)
                    
                    Button {
                        showPopover.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showPopover) {
                        Text("Omit https:// and /v1/ from the URL.\nCorrect input example: api.openai.com")
                            .padding()
                            .presentationCompactAdaptation(.popover)
                    }
                }
                
                SecretInputView(label: provider.type == .github ? "Personal Access Token" : "API Key", secret: $provider.apiKey)
            } header: {
                Text("Host Settings")
            } footer: {
                SectionFooterView(text: provider.type.extraInfo)
            }
    
            Section {
                ModelPicker(model: $provider.chatModel, models: provider.chatModels, label: "Chat Model")
                
                ModelPicker(model: $provider.liteModel, models: provider.chatModels, label: "Lite Model")
            } header: {
                Text("Default Models")
            } footer: {
                SectionFooterView(text: "Recommended to use cheaper models as lite model")
            }

            Section("Customisation") {
                HStack {
                    Text("Accent Color")
                    
                    Button {
                        color = Color.getRandomColor()
                    } label: {
                        Image(systemName: "die.face.5")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .rotationEffect(.degrees(45))
                    
                    Spacer()
                    
                    ColorPicker("Accent Color", selection: $color)
                        .labelsHidden()
                }
                .task {
                    color = Color(hex: provider.color)
                }
                .onChange(of: color) {
                    provider.color = color.toHex()
                }
            }
        }
        .navigationTitle(provider.name)
        .formStyle(.grouped)
        .scrollContentBackground(.visible)
        .toolbar {
            Toggle("Enabled", isOn: $provider.isEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .disabled(provider == providerDefaults.first!.defaultProvider)
        }
    }
    
    private var header: some View {
        HStack {
            ProviderImage(provider: provider, frame: 33, scale: .large)
            
            Group {
            #if os(macOS)
                TextEditor(text: $provider.name)
            #else
                TextField("Name", text: $provider.name)
            #endif
            }
                .textEditorStyle(.plain)
            #if os(macOS)
                .font(.title)
            #else
                .font(.title2)
            #endif
                .padding(5)
                .onChange(of: provider.name) {
                    provider.name = String(provider.name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(18))
                }
            
            Spacer()
            
            defaultSetter
        }
    }
    
    @ViewBuilder
    private var defaultSetter: some View {
        if provider == providerDefaults.first!.defaultProvider {
            Text("DEFAULT")
                .font(.body)
                .foregroundStyle(.secondary)
            
        } else {
            Button {
                providerDefaults.first!.defaultProvider = provider
            } label: {
                Text("Set as Default")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.blue)
        }
    }
}

#Preview {
    ProviderGeneral(provider: .openAIProvider)
        .padding()
        .frame(width: 500, height: 600)
}
