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
//    var models: [Model]
//    var navigationTitle: String
    
    @State var showAPIKey = false
    
    var body: some View {
        #if os(macOS)
            ScrollView {
                GroupBox(label: Text("Service Settings").font(.headline).padding(.bottom, 5)) {
                    settings
                }
                .padding()
            }
        #else
            Form {
                Section("Default Settings") {
                    settings
                }
                .navigationTitle(navigationTitle)
            }
        #endif
    }
    
    var settings: some View {
        VStack {
            HStack {
                Text("Default Model")
                Spacer()
                Picker("", selection: $model) {
                    ForEach(provider.models, id: \.self) { model in
                        Text(model.name)
                            .tag(model.rawValue)
                    }
                }
                .labelsHidden()
                .frame(width: widthValue)
            }
            .padding(paddingValue)
            

            
            if provider == .custom {
                Divider()
                
                HStack {
                    Text("Host URL")
                    Spacer()
                    TextField("Include https", text: configuration.$Chost)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: widthValue)
                }
                .padding(paddingValue)
            }
            
            if provider == .gpt4free {
                HStack {
                    Text("Ignore Web")
                    Spacer()
                    Picker("", selection: $configuration.ignore_web) {
                        ForEach(["True", "False"], id: \.self) { bool in
                            Text(bool)
                                .tag(bool)
                        }
                    }
                    .labelsHidden()
                    .frame(width: widthValue)
                }
                .padding(paddingValue)
            }
            
            if provider != .gpt4free {
                Divider()
                
                HStack {
                    Text("API Key")
                    Spacer()
                    
                    HStack {
                        if showAPIKey {
                            TextField("", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
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
                    .frame(width: widthValue)
                }
                .padding(paddingValue)
            }
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

