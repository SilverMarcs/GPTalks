//
//  PAISettingsView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/4/7.
//

import SwiftUI

struct PAISettingsView: View {
    @StateObject var configuration = AppConfiguration.shared

    @State private var showAPIKey = false

    var body: some View {
        #if os(macOS)
            macOS
        #else
            iOS
        #endif
    }
    
    let paddingValue: CGFloat = 10

    var macOS: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Default Settings")
                    .bold()
                GroupBox {
                    HStack {
                        Text("Model")
                        Spacer()
                        Picker("", selection: configuration.$Cmodel) {
                            ForEach(AIProvider.custom.models, id: \.self) { model in
                                Text(model.name)
                                    .tag(model.id)
                            }
                        }
                        .frame(width: 250)
                    }
                    .padding(paddingValue)

                    Divider()

                    HStack {
                        Text("Context Length")
                        Spacer()
                        Picker("", selection: configuration.$CcontextLength) {
                            ForEach(Array(1 ... 10).reversed() + [30], id: \.self) { number in
                                Text(number == 30 ? "Unlimited Messages" : "Last \(number) Messages")
                                    .tag(number)
                            }
                        }
                        .frame(width: 250)
                    }
                    .padding(paddingValue)

                    Divider()

                    HStack {
                        Text("Temperature")
                        Spacer()
                        HStack {
                            Slider(value: configuration.$Ctemperature, in: 0 ... 2, step: 0.1) {
                            } minimumValueLabel: {
                                Text("0")
                            } maximumValueLabel: {
                                Text("2")
                            }
                            Text(String(format: "%.2f", configuration.Ctemperature))
                        }
                        .frame(width: 240)
                    }
                    .padding(paddingValue)

                    Divider()
                    
                    HStack {
                        Text("System prompt")
                        Spacer()
                        TextField("System Prompt", text: configuration.$ORsystemPrompt)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 240)
                    }
                    .padding(paddingValue)
                    
                    Divider()
                    
                    HStack {
                        Text("Host URL")
                        Spacer()
                        TextField("Include https:// or http://", text: configuration.$CHost)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 240)
                    }
                    .padding(paddingValue)

                }
                .padding(.bottom)

                Text("PAI API Key")
                    .bold()
                GroupBox {
                    HStack {
                        Image(systemName: "key")
                        if showAPIKey {
                            TextField("", text: configuration.$Ckey)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("", text: configuration.$Ckey)
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
                    .padding(paddingValue)
                }
            }
            .padding()
        }
    }

    var iOS: some View {
        Form {
            Section(header: Text("Default Parameters")) {
                Picker(selection: $configuration.Cmodel, label: Text("Model")) {
                    ForEach(AIProvider.custom.models, id: \.self) { model in
                        Text(model.name).tag(model.id)
                    }
                }
                Picker(selection: $configuration.CcontextLength, label: Text("Context Length")) {
                    ForEach(Array(1 ... 10).reversed() + [30], id: \.self) { number in
                        Text(number == 30 ? "Unlimited Messages" : "Last \(number) Messages").tag(number)
                    }
                }
                Stepper(value: $configuration.Ctemperature, in: 0 ... 2, step: 0.1) {
                    HStack {
                        Text("Temperature")
                        Spacer()
                        Text(String(format: "%.1f", configuration.Ctemperature))
                    }
                }
            }
            Section(header: Text("System Prompt")) {
                TextField("Enter a System Prompt", text: $configuration.CsystemPrompt, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
            Section(header: Text("Custom API Key")) {
                HStack {
                    
                    Image(systemName: "key")
                    Spacer()
                    if showAPIKey {
                        TextField("", text: $configuration.Ckey)
                    } else {
                        SecureField("", text: $configuration.Ckey)
                    }
                    Button {
                        showAPIKey.toggle()
                    } label: {
                        Image(systemName: showAPIKey ? "eye.slash" : "eye")
                    }
                }
                HStack {
                    Text("Host URL")
                    Spacer()
                    TextField("Include https:// or http://", text: configuration.$CHost)
                }
            }
            

            
            
        }
        .navigationTitle("PAI")
    }
}
