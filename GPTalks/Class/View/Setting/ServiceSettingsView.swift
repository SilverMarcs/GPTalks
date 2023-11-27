//
//  DefaultConfigView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 21/11/2023.
//

import SwiftUI

struct ServiceSettingsView: View {
    @Binding var model: Model
    @Binding var apiKey: String
    @ObservedObject var configuration = AppConfiguration.shared
    var provider: Provider

    @State var showAPIKey = false

    var body: some View {
        #if os(macOS)
            macOS
        #else
            iOS
        #endif
    }

    var macOS: some View {
        ScrollView {
            VStack(spacing: 30) {
                GroupBox(label: Text("Provider Settings").bold()) {
                    HStack {
                        Text("Default Model")
                        Spacer()
                        modelPicker
                            .labelsHidden()
                            .frame(width: widthValue)
                    }
                    .padding(paddingValue)
                }

                GroupBox(label: Text("API Settings").bold()) {
                    HStack {
                        Text("API Key")
                        Spacer()

                        apiKeyField
                            .textFieldStyle(.roundedBorder)
                            .frame(width: widthValue)
                    }
                    .padding(paddingValue)

                    if provider == .gpt4free {
                        Divider()

                        HStack {
                            Text("Ignore Web")
                            Spacer()
                            ignoreWeb
                                .labelsHidden()
                                .frame(width: widthValue)
                        }
                        .padding(paddingValue)
                    }
                }
            }
        }
        .padding()
    }

    var iOS: some View {
        Form {
            Section("Default Settings") {
                modelPicker

                if provider == .custom {
                    hostUrl
                }

                if provider == .gpt4free {
                    ignoreWeb
                }
            }
            Section("API Key") {
                apiKeyField
            }
        }
        .navigationTitle(provider.name)
    }

    var modelPicker: some View {
        Picker("Default Model", selection: $model) {
            ForEach(provider.models, id: \.self) { model in
                Text(model.name)
                    .tag(model.rawValue)
            }
        }
    }

    var hostUrl: some View {
        HStack {
            TextField("Host URL (include https)", text: configuration.$Chost)
        }
    }

    var ignoreWeb: some View {
        Picker("Ignore Web", selection: configuration.$ignoreWeb) {
            Text("True").tag("True")
            Text("False").tag("False")
        }
    }

    var apiKeyField: some View {
        HStack {
            if showAPIKey {
                TextField("", text: $apiKey)
            } else {
                SecureField("", text: $apiKey)
            }
            Button {
                showAPIKey.toggle()
            } label: {
                if showAPIKey {
                    Image(systemName: "eye.slash")
                } else {
                    Image(systemName: "eye")
                }
            }
            .buttonStyle(.borderless)
        }
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
            240
        #else
            180
        #endif
    }
}
