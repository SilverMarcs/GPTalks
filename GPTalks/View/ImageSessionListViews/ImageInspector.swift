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
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
    
    @Binding var showingInspector: Bool
    
    var filteredProviders: [Provider] {
        providers.filter { !$0.imageModels.isEmpty }
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
                                   providers: providers) { provider in
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
                    
                    Picker("Size", selection: $session.config.size) {
                        ForEach(ImagesQuery.Size.allCases, id: \.self) { size in
                            Text(size.rawValue.capitalized).tag(size)
                        }
                    }
                    
                    Picker("Quality", selection: $session.config.quality) {
                        ForEach(ImagesQuery.Quality.allCases, id: \.self) { quality in
                            Text(quality.rawValue.uppercased()).tag(quality)
                        }
                    }
                    
                    Picker("Style", selection: $session.config.style) {
                        ForEach(ImagesQuery.Style.allCases, id: \.self) { style in
                            Text(style.rawValue.capitalized).tag(style)
                        }
                    }
                }
            }
            .toolbar {
                Text("Config")
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    showingInspector.toggle()
                } label: {
                    #if os(macOS)
                    Label("Toggle Inspector", systemImage: "sidebar.right")
                    #else
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray, .gray.opacity(0.3))
                    #endif
                }
            }
            .formStyle(.grouped)
            #if os(macOS)
            .scrollDisabled(true)
            #endif
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

#Preview {
    ImageInspector(session: .mockImageSession, showingInspector: .constant(true))
}
