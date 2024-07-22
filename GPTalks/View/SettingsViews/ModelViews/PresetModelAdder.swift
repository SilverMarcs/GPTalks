//
//  PresetModelAdder.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct PresetModelAdder: View {
    var provider: Provider
    
    var body: some View {
        Menu {
            Button {
                provider.addOpenAIModels()
            } label: {
                Text("OpenAI Models")
            }

            Button {
                provider.addClaudeModels()
            } label: {
                Text("Anthropic Models")
            }

            Button {
                provider.addGoogleModels()
            } label: {
                Text("Google Models")
            }

        } label: {
            Label("Presets", systemImage: "cpu")
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .fixedSize()
    }
}

#Preview {
    PresetModelAdder(provider: Provider.factory(type: .openai))
}
