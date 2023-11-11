//
//  OpenAISettingsView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/4/7.
//

import SwiftUI

struct OpenAISettingsView: View {
    
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
                        Picker(selection: configuration.$OAImodel) {
                            ForEach(AIProvider.openAI.models, id: \.self) { model in
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
                        Picker(selection: configuration.$OAIcontextLength) {
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
                        Slider(value: configuration.$OAItemperature, in: 0...2) {
                            
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("2")
                        }
                        .width(215)
                        Text(String(format: "%.2f", configuration.OAItemperature))
                            .width(30)
                    }
                    .padding()
                    
                    Divider()
                    
                    TextField("System Prompt", text: configuration.$OAIsystemPrompt)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                .padding(.bottom)
                
                Text("OpenAI API Key")
                    .bold()
                GroupBox {
                    HStack {
                        Image(systemName: "key")
                        if showAPIKey  {
                            TextField("", text: configuration.$OAIkey)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("", text: configuration.$OAIkey)
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
                    Link("OpenAI Documentation", destination: URL(string: "https://platform.openai.com/docs/introduction")!)
                }
                .padding(.bottom)
            }
            .padding()
        }

    }
    
    
    var iOS: some View {
       Form {
           Section(header: Text("Default Parameters")) {
               Picker(selection: $configuration.OAImodel, label: Text("Model")) {
                   ForEach(AIProvider.openAI.models, id: \.self) { model in
                      Text(model.name).tag(model.id)
                   }
               }
               Picker(selection: $configuration.OAIcontextLength, label: Text("Context Length")) {
                   ForEach(Array(1...10).reversed() + [30], id: \.self) { number in
                      Text(number == 30 ? "Unlimited Messages" : "Last \(number) Messages").tag(number)
                   }
               }
               Stepper(value: $configuration.OAItemperature, in: 0...2, step: 0.1) {
                   HStack {
                      Text("Temperature")
                      Spacer()
                      Text(String(format: "%.1f", configuration.OAItemperature))
                   }
               }
           }
           Section(header: Text("System Prompt")) {
               TextField("Enter a System Prompt", text: $configuration.OAIsystemPrompt, axis: .vertical)
                   .lineLimit(3, reservesSpace: true)
           }
           Section(header: Text("OpenAI API Key")) {
               HStack {
                   Image(systemName: "key")
                   Spacer()
                   if showAPIKey {
                      TextField("", text: $configuration.OAIkey)
                   } else {
                      SecureField("", text: $configuration.OAIkey)
                   }
                   Button {
                      showAPIKey.toggle()
                   } label: {
                      Image(systemName: showAPIKey ? "eye.slash" : "eye")
                   }
               }
           }
       }
       .navigationTitle("OpenAI")
    }

}
