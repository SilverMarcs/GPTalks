//
//  EmptyConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/09/2024.
//

import SwiftUI

struct EmptyConversationList: View {
    @Bindable var session: Session
    var providers: [Provider]
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    ProviderImage(provider: session.config.provider, radius: 6, frame: 18, scale: .small)
                    
                    ProviderPicker(provider: $session.config.provider, providers: providers) { provider in
                        session.config.model = provider.chatModel
                    }
                    .labelsHidden()
                    .buttonStyle(.borderless)
                    .fixedSize()
                }
                
                ModelPicker(model: $session.config.model, models: session.config.provider.chatModels, label: "Model")
                    .labelsHidden()
                    .buttonStyle(.borderless)
                    .fixedSize()
                
                HStack(spacing: 2) {
                    Image(systemName: session.config.tools.enabledTools.isEmpty ? "hammer": "hammer.fill")
                        .contentTransition(.symbolEffect(.replace))
                        .foregroundStyle(.teal)
                    
                    Menu {
                        ToolsController(tools: $session.config.tools)
                    } label: {
                        Text("^[\(session.config.tools.enabledTools.count) Plugin](inflect: true)")
                    }
                    .menuStyle(SimpleIconOnly())
                }
                
                Spacer()
            }
            .padding()
            
            Spacer()
            
            Image(session.config.provider.type.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.quaternary)
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

#Preview {
    let config = SessionConfig()
    let session = Session(config: config)
    let provider = Provider.factory(type: .openai)
    
    EmptyConversationList(session: session, providers: [provider])
}
