//
//  ToolbarItems.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

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
