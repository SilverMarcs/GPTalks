//
//  ProviderGeneral.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ProviderGeneral: View {
    @Bindable var provider: Provider
    @ObservedObject var providerManager = ProviderManager.shared

    @State private var color =
        Color(.sRGB, red: 1, green: 1, blue: 1)

    var body: some View {
        Form {
            Section {
                header
            }
            
            Section("Host Settings") {
                TextField("Host URL", text: $provider.host)
                
                TextField("API Key", text: $provider.apiKey)
                    .truncationMode(.middle)
                

            }
    
            Section("Default Models") {
                Picker("Chat Model", selection: $provider.chatModel) {
                    ForEach(provider.models, id: \.self) { model in
                        Text(model.name).tag(model)
                    }
                }
                
                Picker("Title Model", selection: $provider.titleModel) {
                    ForEach(provider.models, id: \.self) { model in
                        Text(model.name).tag(model)
                    }
                }
            }

            Section("Customisation") {
                ColorPicker("Accent Color", selection: $color)
                    .onAppear {
                        color = Color(hex: provider.color)
                    }
                    .onChange(of: color) {
                        provider.color = color.toHex()
                    }
                Picker("Type", selection: $provider.type) {
                    ForEach(ProviderType.allCases, id: \.self) { type in
                        Text(type.name).tag(type)
                    }
                }
            }

        }
        .formStyle(.grouped)
    }
    
    private var header: some View {
        HStack {
            ProviderImage(provider: provider, frame: 33)
            
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
    
    private var defaultSetter: some View {
        Group {
            if provider.id.uuidString == providerManager.defaultProvider {
                Text("DEFAULT")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
            } else {
                Button {
                    providerManager.defaultProvider = provider.id.uuidString
                } label: {
                    Text("Set as Default")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    let provider = Provider.factory(type: .openai)

    return ProviderGeneral(provider: provider)
        .padding()
        .frame(width: 500)
}
