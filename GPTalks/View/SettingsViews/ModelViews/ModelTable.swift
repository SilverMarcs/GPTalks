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
        #if os(macOS)
        modelTable
            .padding()
        #else
        modelList
        #endif
    }
    
    @ViewBuilder
    var modelTable: some View {
        VStack {
            Table(of: Model.self) {
                TableColumn("Code") { model in
                    TextField(
                        "Code",
                        text: Binding(
                            get: { model.code },
                            set: { model.code = $0 }
                        ))
                    
                }
                
                TableColumn("Name") { model in
                    TextField(
                        "Name",
                        text: Binding(
                            get: { model.name },
                            set: { model.name = $0 }
                        ))
                    
                }
                
                TableColumn("Action") { model in
                    Button {
                        removeModel(model: model)
                    } label: {
                        Label("Remove", systemImage: "minus.circle.fill")
                            .foregroundStyle(.red)
                            .labelStyle(.iconOnly)
                    }
                }
            } rows: {
                ForEach(
                    provider.models, id: \.self
                ) { model in
                    TableRow(model)
                }
            }
            
            modelAdder
        }
    }
    
    #if !os(macOS)
    var modelList: some View {
        VStack(alignment: .trailing, spacing: 10) {
            List {
                ForEach(provider.models, id: \.self) { model in
                    ModelRow(model: model)
                }
                
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                header
            }
        }
    }
    #endif

    private var header: some View {
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
            Label("Add", systemImage: "cpu")
        }
        .menuStyle(SimpleIconOnly())
    }

    private func removeModel(model: Model) {
        withAnimation {
            model.removeSelf()
        }
    }

    var modelAdder: some View {
        HStack {
            header
            
            TextField("New Code", text: $newModelCode)
            TextField("New Name", text: $newModelName)
            Button(action: addModel) {
                Label("Add", systemImage: "plus.circle")
            }
            .buttonStyle(.borderedProminent)
        }
        .textFieldStyle(.roundedBorder)
    }

    private func addModel() {
        if newModelCode.isEmpty || newModelName.isEmpty {
            return
        }

        let model = Model(
            code: newModelCode, name: newModelName, provider: provider)
        
        withAnimation {
            provider.models.append(model)
        }

        newModelCode = ""
        newModelName = ""
    }

}

#Preview {
    let provider = Provider.factory(type: .openai)

    ModelTable(provider: provider)
        .modelContainer(for: Provider.self, inMemory: true)
}
