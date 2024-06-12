//
//  ServiceSettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 21/11/2023.
//

import SwiftUI

struct ServiceSettingsView: View {
    @Binding var chatModel: Model
    @Binding var imageModel: Model
    @Binding var apiKey: String
    @Binding var color: ProviderColor
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
                GroupBox(label: Text("Provider Settings")) {
                    HStack {
                        Text("Default Chat Model")
                        Spacer()
                        chatModelPicker
                            .labelsHidden()
                            .frame(width: widthValue)
                    }
                    .padding(paddingValue)
                    
                    Divider()
                    
                    HStack {
                        Text("Default Image Model")
                        Spacer()
                        imageModelPicker
                            .labelsHidden()
                            .frame(width: widthValue)
                    }
                    .padding(paddingValue)
                }
                
                GroupBox(label: Text("Appearance")) {
                    HStack {
                        Text("Provider Color")
                        Spacer()
                        colorPicker
                            .labelsHidden()
                            .frame(width: widthValue)
                        }
                    .padding(paddingValue)
                }
            
                GroupBox(label: Text("API Settings")) {
                    if provider == .custom {
                        HStack {
                            Text("Host URL")
                            Spacer()
                        
                            hostUrl
                                .textFieldStyle(.roundedBorder)
                                .frame(width: widthValue)
                        }
                        .padding(paddingValue)
                    
                        Divider()
                    }
                
                    HStack {
                        Text("API Key")
                        Spacer()
                    
                        apiKeyField
                            .textFieldStyle(.roundedBorder)
                            .frame(width: widthValue)
                    }
                    .padding(paddingValue)
                }
            
                if provider == .custom {
                    GroupBox(label: Text("Custom Models")) {
                        HStack {
                            Text("Chat")
                            Spacer()
                            CustomChatModel()
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 250)
                        }
                        .padding(paddingValue)
                    
                        Divider()
                    
                        HStack {
                            Text("Image")
                            Spacer()
                            CustomImageModel()
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 250)
                        }
                        .padding(paddingValue)
                    
                        Divider()
                    
                        HStack {
                            Text("Vision")
                            Spacer()
                            CustomVisionModel()
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 250)
                        }
                        .padding(paddingValue)
                    }
                }
            
                Spacer()
            }
            .padding()
        }
    }

    var iOS: some View {
        Form {
            Section("Default Models") {
                chatModelPicker
                imageModelPicker
            }
            
            Section("Appearance") {
                colorPicker
            }
            
            Section("API Settings") {
                if provider == .custom {
                    hostUrl
                }
                
                apiKeyField
            }
            
            if provider == .custom {
                Section("Custom Models") {
                    HStack {
                        Text("Chat: ")
                        CustomChatModel()
                    }
                    
                    HStack {
                        Text("Image: ")
                        CustomImageModel()
                    }
                    
                    HStack {
                        Text("Vision: ")
                        CustomVisionModel()
                    }
                }
            }
        }
        .navigationTitle(provider.name)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    var chatModelPicker: some View {
        Picker("Default Chat Model", selection: $chatModel) {
            ForEach(provider.chatModels, id: \.self) { model in
                Text(model.name)
                    .tag(model.rawValue)
            }
        }
    }
    
    var imageModelPicker: some View {
        Picker("Default Image Model", selection: $imageModel) {
            ForEach(provider.imageModels, id: \.self) { model in
                Text(model.name)
                    .tag(model.rawValue)
            }
        }
    }
    
    var colorPicker: some View {
        Picker("Provider Color", selection: $color) {
            ForEach(ProviderColor.allCases, id: \.self) { color in
                Text(color.name)
                    .tag(color.rawValue)
            }
        }
    }

    var hostUrl: some View {
        HStack {
            TextField("Host URL (omit https and /v1/x/x)", text: configuration.$Chost)
        }
    }

    var apiKeyField: some View {
        HStack {
            if showAPIKey {
                TextField("API Key", text: $apiKey)
            } else {
                SecureField("API Key", text: $apiKey)
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
