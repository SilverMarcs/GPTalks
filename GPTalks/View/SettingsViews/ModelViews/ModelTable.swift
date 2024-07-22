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
    @State var supportsImage: Bool = false

    var body: some View {
        #if os(macOS)
        modelTable
        #else
        modelList
        #endif
    }
    
    @ViewBuilder
    var modelTable: some View {
            Form {
                modelAdder
                
                Section("") {
                    Table(of: Model.self) {
                        TableColumn("Image") { model in
                            Toggle(
                                "Image",
                                isOn: Binding(
                                    get: { model.supportsImage },
                                    set: { model.supportsImage = $0 }
                                ))
                            .labelsHidden()
                            
                        }
                        
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
                            provider.models.sorted { $0.supportsImage && !$1.supportsImage }, id: \.self
                        ) { model in
                            TableRow(model)
                        }
                    }
                    .labelsHidden()
                }
                .padding(.top, -50)
            }
            .formStyle(.grouped)
    }
    
    #if !os(macOS)
    var modelList: some View {
        List {
            HStack {
                Group {
                    Text("Image")
                    Text("Code")
                    Text("Name")
                }
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ForEach(provider.models, id: \.self) { model in
                ModelRow(model: model)
            }
            
            Section ("Add New"){
                Toggle("Supports Image", isOn: $supportsImage)
                    .toggleStyle(.checkbox)
                    .labelsHidden()
                TextField("New Code", text: $newModelCode)
                TextField("New Name", text: $newModelName)
                Button(action: addModel) {
                    Label("Add", systemImage: "plus")
                }
            }
            
        }
        .scrollDismissesKeyboard(.immediately)
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

    private func removeModel(model: Model) {
        model.removeSelf()
    }

    #if os(macOS)
    var modelAdder: some View {
        Group {
            HStack {
                header
                
                Spacer()
                
                Button(action: addModel) {
                    Label("Add", systemImage: "plus.circle")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }
            
            HStack {
                Toggle("Supports Image", isOn: $supportsImage)
                    .help("Supports Image")
                    .toggleStyle(.checkbox)
                    .labelsHidden()
                TextField("Code ", text: $newModelCode)
                TextField("Name ", text: $newModelName)
            }
        }
    }
    #else
    var modelAdder: some View {
        HStack {
            header
            
            TextField("Code", text: $newModelCode)
            TextField("Name", text: $newModelName)
            Button(action: addModel) {
                Label("Add", systemImage: "plus.circle")
            }
            .buttonStyle(.borderedProminent)
        }
        .textFieldStyle(.roundedBorder)
    }
    #endif

    private func addModel() {
        if newModelCode.isEmpty || newModelName.isEmpty {
            return
        }

        let model = Model(
            code: newModelCode, name: newModelName, provider: provider, supportsImage: supportsImage)
        
        provider.models.append(model)

        supportsImage = false
        newModelCode = ""
        newModelName = ""
    }

}

#Preview {
    let provider = Provider.factory(type: .openai)

    ModelTable(provider: provider)
        .modelContainer(for: Provider.self, inMemory: true)
}
