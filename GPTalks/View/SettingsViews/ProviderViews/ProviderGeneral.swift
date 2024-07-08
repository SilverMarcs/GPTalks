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
            Section("Host Settings") {
                TextField("Name", text: $provider.name)
                if provider.type == .google {
                    TextField("Host URL", text: .constant("generativelanguage.googleapis.com"))
                        .disabled(true)
                } else {
                    TextField("Host URL", text: $provider.host)
                }
                SecureField("API Key", text: $provider.apiKey)
            }

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
}

#Preview {
    let provider = Provider.getDemoProvider()

    ProviderGeneral(provider: provider)
        .padding()
        .frame(width: 500)
}
