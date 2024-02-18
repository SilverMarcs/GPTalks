//
//  ToolbarItems.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

struct ToolbarItems: ToolbarContent {
    @Bindable var session: DialogueSession

    @State var isShowSettingsView: Bool = false

    var body: some ToolbarContent {
        #if os(macOS)
            macOS
        #else
            iOS
        #endif
    }

    #if !os(macOS)
        @ToolbarContentBuilder
        var iOS: some ToolbarContent {
            #if !os(visionOS)
                ToolbarItem(placement: .principal) {
                    HStack {
                        Button {
                            isShowSettingsView.toggle()
                        } label: {
                            iosNavTitle
                        }
                        .foregroundStyle(.primary)
                        .sheet(isPresented: $isShowSettingsView) {
                            DialogueSettingsView(session: session)
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }
//                .padding(.leading, -5)
                }
            #endif
            
//                    #if !os(visionOS)
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Text("\(session.getMessageCountAfterResetMarker())/\(session.configuration.contextLength)")
//                            .font(.callout)
//                            .opacity(0.7)
//                    }
//                    #else
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button {
//                            isShowSettingsView = true
//                        } label: {
//                            Text("Config")
//                        }
//                        .sheet(isPresented: $isShowSettingsView) {
//                            DialogueSettingsView(session: session)
//                        }
//                    }
//                    #endif
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Section {
                        Menu {
                            providerPicker
                        } label: {
                            Label("Provider", systemImage: "building.2")
                        }
                        
                        Menu {
                            modelPicker
                        } label: {
                            Label("Model", systemImage: "cube.box")
                        }
                        
                        Menu {
                            tempPicker
                        } label: {
                            Label("Temperature", systemImage: "thermometer.high")
                        }
                        
                        Menu {
                            contextPicker
                        } label: {
                            Label("Context", systemImage: "clock.arrow.circlepath")
                        }
                    }
                    
                    Section {
                        Menu {
                            Button(role: .destructive) {
                                session.removeAllConversations()
                            } label: {
//                                Text("Delete All Messages")
//                                Image(systemName: "trash")
                                Label("All Messages", systemImage: "trash")
                            }
                        } label: {
                            Label("Delete Messages", systemImage: "trash")
                        }
                    }
                
                } label: {
                    Label("Config", systemImage: "ellipsis.circle")
                }
            }
        }

        var iosNavTitle: some View {
            HStack {
                ProviderImage(radius: 9, color: session.configuration.provider.accentColor, frame: 30)
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 4) {
                        Text(session.title)
                            .font(.system(size: 16))
                            .foregroundStyle(.primary)
                            .bold()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                    }
                    HStack(spacing: 3) {
                        Group {
//                            Text(session.configuration.model.name)
//                            
//                            Text("•")

                            Text(session.configuration.systemPrompt)
                                .frame(maxWidth: 200, alignment: .leading)
//                            Text("Temperature: " + String(session.configuration.temperature))
                        }
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
    #endif

    @ToolbarContentBuilder
    var macOS: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button {
                isShowSettingsView = true
            } label: {
                Image(systemName: "square.text.square")
            }
            .popover(isPresented: $isShowSettingsView) {
                VStack {
                    Text("System Prompt")
                    TextEditor(text: $session.configuration.systemPrompt)
                        .font(.body)
                        .frame(width: 230, height: 70)
                        .scrollContentBackground(.hidden)
                }
                .padding(10)
            }
        }

        ToolbarItemGroup {
            Picker("Provider", selection: $session.configuration.provider) {
                ForEach(Provider.availableProviders, id: \.self) { provider in
                    Text(provider.name)
                        .tag(provider.id)
                }
            }

            Slider(value: $session.configuration.temperature, in: 0 ... 2, step: 0.2) {} minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("2")
            }
            .frame(width: 130)

            modelPicker
                .frame(width: 110)

            Menu {
                contextPicker

                Button("Regenerate") {
                    Task {
                        await session.regenerateLastMessage()
                    }
                }
                
                Button("Reset Context") {
                    session.resetContext()
                }

                Button("Delete All Messages") {
                    session.removeAllConversations()
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuIndicator(.hidden)
        }
    }
    
    var tempPicker: some View {
        Picker("Temperature", selection: $session.configuration.temperature) {
            ForEach(stride(from: 0.0, through: 2.0, by: 0.2).map { $0 }, id: \.self) { temp in
                Text(String(format: "%.1f", temp)).tag(temp)
            }
        }
    }
    
    var providerPicker: some View {
        Picker("Provider", selection: $session.configuration.provider) {
            ForEach(Provider.availableProviders, id: \.self) { provider in
                Text(provider.name)
                    .tag(provider.id)
            }
        }
    }
    
    var modelPicker: some View {
        Picker("Model", selection: $session.configuration.model) {
            if session.containsConversationWithImage || session.inputImage != nil {
                ForEach(session.configuration.provider.visionModels, id: \.self) { model in
                    Text(model.name)
                        .tag(model.id)
                }
                
            } else {
                ForEach(session.configuration.provider.visionModels + session.configuration.provider.chatModels, id: \.self) { model in
                    Text(model.name)
                        .tag(model.id)
                }
            }
        }
    }
    
    var contextPicker: some View {
        Picker("Context Length", selection: $session.configuration.contextLength) {
            ForEach(Array(stride(from: 2, through: 20, by: 2)), id: \.self) { number in
                Text("\(number) Messages")
                    .tag(number)
            }
        }
    }
}
