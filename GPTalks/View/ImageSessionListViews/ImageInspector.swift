//
//  ImageInspector.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData
import OpenAI

struct ImageInspector: View {
    @Bindable var session: ImageSession
    @Query(filter: #Predicate { $0.isEnabled && $0.supportsImage }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
    
    var openaiProviders: [Provider] {
        providers.filter { $0.type == .openai }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    HStack(spacing: 0) {
                        TextField("Title", text: $session.title)
                            .labelsHidden()
                        
                        Spacer()
                        
                        generateTitle
                    }
                }
                
                Section("Models") {
                    ProviderPicker(provider: $session.config.provider,
                                   providers: openaiProviders) { provider in
                        session.config.model = provider.imageModel
                    }
                    
                    ModelPicker(model: $session.config.model, models: session.config.provider.imageModels, label: "Model")
                }
                
                Section("Parameters") {
                    Picker("N", selection: $session.config.numImages) {
                        ForEach(1 ... 4, id: \.self) { num in
                            Text(String(num)).tag(num)
                        }
                    }
                    
                    Picker("Quality", selection: $session.config.quality) {
                        ForEach(ImagesQuery.Quality.allCases, id: \.self) { quality in
                            Text(quality.rawValue.uppercased()).tag(quality)
                        }
                    }
                    
                    Picker("Size", selection: $session.config.size) {
                        ForEach(ImagesQuery.Size.allCases, id: \.self) { size in
                            Text(size.rawValue.capitalized).tag(size)
                        }
                    }
                    
                    Picker("Style", selection: $session.config.style) {
                        ForEach(ImagesQuery.Style.allCases, id: \.self) { style in
                            Text(style.rawValue.capitalized).tag(style)
                        }
                    }
                }
            }
            .formStyle(.grouped)
        }
    }
    
    private var generateTitle: some View {
        Button {
            Task { await session.generateTitle(forced: true) }
        } label: {
            Image(systemName: "sparkles")
        }
        .buttonStyle(.plain)
        .foregroundStyle(.mint.gradient)
    }
    
    private var deleteAllMessages: some View {
        Button(role: .destructive) {
            session.deleteAllGenerations()
        } label: {
            HStack {
                Spacer()
                Text("Delete All Generations")
                Spacer()
            }
        }
        .foregroundStyle(.red)
    }
}

//#Preview {
//    ImageInspector()
//}
