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
                        Text("Model")
                        Spacer()
                        Picker(selection: configuration.$ORmodel) {
                            ForEach(AIProvider.openRouter.models, id: \.self) { model in
                                Text(model.name)
                                    .tag(model.id)
                            }
                        }
                        .frame(width: 250)
                    }
                    .padding()
                    
                    Divider()
                    
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
           Section(header: Text("Default Parameters")) {
               Picker(selection: $configuration.ORmodel, label: Text("Model")) {
                   ForEach(AIProvider.openRouter.models, id: \.self) { model in
                      Text(model.name).tag(model.id)
                   }
               }
               Picker(selection: $configuration.ORcontextLength, label: Text("Context Length")) {
                   ForEach(Array(1...10).reversed() + [30], id: \.self) { number in
                      Text(number == 30 ? "Unlimited Messages" : "Last \(number) Messages").tag(number)
                   }
               }
               Stepper(value: $configuration.ORtemperature, in: 0...2, step: 0.1) {
                   HStack {
                      Text("Temperature")
                      Spacer()
                      Text(String(format: "%.1f", configuration.ORtemperature))
                   }
               }
           }
           Section(header: Text("System Prompt")) {
               TextField("Enter a System Prompt", text: $configuration.ORsystemPrompt, axis: .vertical)
                   .lineLimit(3, reservesSpace: true)
           }
           Section(header: Text("OpenRouter API Key")) {
               HStack {
                   Image(systemName: "key")
                   Spacer()
                   if showAPIKey {
                      TextField("", text: $configuration.ORkey)
                   } else {
                      SecureField("", text: $configuration.ORkey)
                   }
                   Button {
                      showAPIKey.toggle()
                   } label: {
                      Image(systemName: showAPIKey ? "eye.slash" : "eye")
                   }
               }
           }
       }
       .navigationTitle("OpenRouter")
    }

}
