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
    
    @State private var showRenameDialogue = false
    @State private var newName = ""

    var body: some ToolbarContent {
        macOS
    }

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
            providerPicker

            tempSlider
                .frame(width: 130)

            modelPicker
                .frame(width: 110)

            Menu {
                Section {
                    Button("Generate Title") {
                        Task { await session.generateTitle() }
                    }
                }
                Section {
                    contextPicker
                    
                    Button("Regenerate") {
                        Task { await session.regenerateLastMessage() }
                    }
                    
                    Button("Reset Context") {
                        session.resetContext()
                    }
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
    
    var tempSlider: some View {
        Slider(value: $session.configuration.temperature, in: 0 ... 2, step: 0.2) {} minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("2")
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


struct TempPicker: View {
    @Bindable var session: DialogueSession
    
    var body: some View {
        Picker("Temperature", selection: $session.configuration.temperature) {
            ForEach(stride(from: 0.0, through: 2.0, by: 0.2).map { $0 }, id: \.self) { temp in
                Text(String(format: "%.1f", temp)).tag(temp)
            }
        }
    }
}

struct ProviderPicker: View {
    @Bindable var session: DialogueSession

    var body: some View {
        Picker("Provider", selection: $session.configuration.provider) {
            ForEach(Provider.availableProviders, id: \.self) { provider in
                Text(provider.name).tag(provider.id)
            }
        }
    }
}

struct TempSlider: View {
    @Bindable var session: DialogueSession

    var body: some View {
        Slider(value: $session.configuration.temperature, in: 0 ... 2, step: 0.2) {} minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("2")
        }
    }
}

struct ModelPicker: View {
    @Bindable var session: DialogueSession

    var body: some View {
        Picker("Model", selection: $session.configuration.model) {
            if session.containsConversationWithImage || session.inputImage != nil {
                ForEach(session.configuration.provider.visionModels, id: \.self) { model in
                    Text(model.name).tag(model.id)
                }
            } else {
                ForEach(session.configuration.provider.visionModels + session.configuration.provider.chatModels, id: \.self) { model in
                    Text(model.name).tag(model.id)
                }
            }
        }
    }
}

struct ContextPicker: View {
    @Bindable var session: DialogueSession

    var body: some View {
        Picker("Context Length", selection: $session.configuration.contextLength) {
            ForEach(Array(stride(from: 2, through: 20, by: 2)), id: \.self) { number in
                Text("\(number) Messages").tag(number)
            }
        }
    }
}
