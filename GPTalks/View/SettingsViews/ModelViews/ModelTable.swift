//
//  ModelTable.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import SwiftUI

struct ModelTable: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var provider: Provider

    @State var newModelCode: String = ""
    @State var newModelName: String = ""

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {

            header

            VStack(spacing: 0) {
                modelListHeader
                
                Divider()
                    .opacity(0.5)
                
                modelList
            }
        }

    }
    
    private var header: some View {
        HStack {
            Menu {
                Button {
                    provider.addOpenAIModels()
                } label: {
                    Text("Add OpenAI Models")
                }
                
                Button {
                    provider.addClaudeModels()
                } label: {
                    Text("Add Claude Models")
                }
                
                Button {
                    provider.addGoogleModels()
                } label: {
                    Text("Add Google Models")
                }
                
            } label: {
                Label("Add", systemImage: "ellipsis.circle")
            }
            .menuStyle(SimpleIconOnly())
            .frame(width: 10)
            
            
            Picker("Default Model", selection: $provider.chatModel) {
                ForEach(provider.models, id: \.self) { model in
                    Text(model.name).tag(model)
                }
            }
                
            Picker("Quick Model", selection: $provider.quickChatModel) {
                ForEach(provider.models, id: \.self) { model in
                    Text(model.name).tag(model)
                }
            }
        }
        .padding(.horizontal, 8)
    }

    private var modelListHeader: some View {
        HStack {
            Group {
                Text("Code")
                Text("Name")
            }
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(.background)
    }

    private var modelList: some View {
        List {
            ForEach(provider.models, id: \.self) { model in
                ModelRow(model: model)
            }

            modelAdder
        }
        #if os(macOS)
        .alternatingRowBackgrounds()
        #endif
    }

    private var modelAdder: some View {
        Group {
            HStack {
                TextField("New Code", text: $newModelCode)
                
                ZStack(alignment: .trailing) {
                    TextField("New Name", text: $newModelName)
                    
                    Button(action: addModel) {
                        Label("Add", systemImage: "plus")
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }
            }
        }
    }

    private func removeModel(model: Model) {
        model.removeSelf()
    }

    private func addModel() {
        if newModelCode.isEmpty || newModelName.isEmpty {
            return
        }
        
        let model = Model(
            code: newModelCode, name: newModelName, provider: provider)
        provider.models.append(model)

        newModelCode = ""
        newModelName = ""
    }

}

#Preview {
    let provider = Provider.factory(type: .openai)

    ModelTable(provider: provider)
        .modelContainer(for: Provider.self, inMemory: true)
}
