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
                
                SecureField("API Key", text: $provider.apiKey)
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
                .onChange(of: provider.type) {
                    if provider.type == .google {
                        provider.host = "generativelanguage.googleapis.com"
                    } else if provider.type == .openai {
                        provider.host = "api.openai.com"
                    } else if provider.type == .claude {
                        provider.host = "api.anthropic.com"
                    }
                }
            }

        }
        .formStyle(.grouped)
    }
    
    private var header: some View {
        HStack {
            ProviderImage(color: Color(hex: provider.color), frame: 33)

            TextEditor(text: $provider.name)
                .textEditorStyle(.plain)
                .font(.title)
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
    let provider = Provider.getDemoProvider()
    provider.type = .google

    return ProviderGeneral(provider: provider)
        .padding()
        .frame(width: 500)
}
