//
//  RapidAPISettingsView.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 08/11/2023.
//

import SwiftUI

struct SummarySettingsView: View {
    
    @StateObject var configuration = AppConfiguration.shared
    
    @State private var showAPIKey = false
    
    var body: some View {
#if os(macOS)
        settings
#else
        iOS
#endif
    }
    
    var macOS: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                Text("Summary Settings")
                    .bold()
                GroupBox {
                    HStack {
                        Text("Summary Length")
                        Picker("", selection: configuration.$OAIcontextLength) {
                            ForEach(Array(1...3).reversed(), id: \.self) { number in
                                Text("Length \(number) Messages")
                                    .tag(number)
                            }
                        }
                    }
                    .padding()
                    
                }
                .padding(.bottom)

                Text("RapidAPI Key")
                    .bold()
                GroupBox {
                    HStack {
                        Image(systemName: "key")
                        if showAPIKey  {
                            TextField("", text: configuration.$rapidApiKey)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("", text: configuration.$rapidApiKey)
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
//                .padding(.bottom)
                
                HStack {
                    Spacer()
                    Link("Get your RapidAPI Key from here", destination: URL(string: "https://platform.openai.com/docs/introduction")!)
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
//                                .height(32)
//                                .width(60)
//                                .background(Color.secondarySystemFill)
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
