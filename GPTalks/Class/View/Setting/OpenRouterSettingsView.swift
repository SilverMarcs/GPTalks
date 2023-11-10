//
//  OpenRouterSettingsView.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 08/11/2023.
//

import SwiftUI

struct OpenRouterSettingsView: View {
    
    @StateObject var configuration = AppConfiguration.shared
    
    @State private var showAPIKey = false
    
    var body: some View {
#if os(macOS)
        macOS
#else
        iOS
#endif
    }
    
    var macOS: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Default Settings")
                    .bold()
                GroupBox {
                    
                    HStack {
                        Text("Context Length")
                        Spacer()
                        Picker(selection: configuration.$ORcontextLength) {
                            ForEach(Array(1...10).reversed() + [30], id: \.self) { number in
                                Text(number == 30 ? "Unlimited Messages" : "Last \(number) Messages")
                                    .tag(number)
                            }
                        }
                        .frame(width: 250)
                    }
                    .padding()
                    
                    Divider()
                    
                    HStack {
                        Text("Temperature")
                        Spacer()
                        Slider(value: configuration.$ORtemperature, in: 0...2) {
                            
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("2")
                        }
                        .width(215)
                        Text(String(format: "%.2f", configuration.ORtemperature))
                            .width(30)
                    }
                    .padding()
                    
                    Divider()
     
                    TextField("System Prompt", text: configuration.$ORsystemPrompt)
                        .textFieldStyle(.roundedBorder)
                        .padding()

                }
                .padding(.bottom)
                
                Text("OpenRouter API Key")
                    .bold()
                GroupBox {
                    HStack {
                        Image(systemName: "key")
                        if showAPIKey  {
                            TextField("", text: configuration.$ORkey)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("", text: configuration.$ORkey)
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
                    .padding()
                }
                HStack {
                    Spacer()
                    Link("OpenRouter Documentation", destination: URL(string: "https://openrouter.ai/docs")!)
                }
                .padding(.bottom)
            }
            .padding()
        }

    }
    
    
    var iOS: some View {
        Form {
            Section {
                VStack {
                    Stepper(value: $configuration.ORtemperature, in: 0...2, step: 0.1) {
                        HStack {
                            Text("Temperature")
                            Spacer()
                            Text(String(format: "%.1f", configuration.ORtemperature))
                                .padding(.horizontal)
                                .height(32)
                                .width(60)
                                .background(Color.secondarySystemFill)
                                .cornerRadius(8)
                        }
                    }
                }
            } header: {
                Text("Default Settings")
            }
            
            Section {
                HStack {
                    Image(systemName: "key")
                    Spacer()
                    if showAPIKey {
                        TextField("OpenAI API Key", text: $configuration.ORkey)
                            .truncationMode(.middle)
                    } else {
                        SecureField("OpenAI API Key", text: $configuration.ORkey)
                            .truncationMode(.middle)
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
                }
            }
        }
        .navigationTitle("OpenAI")
    }
}
