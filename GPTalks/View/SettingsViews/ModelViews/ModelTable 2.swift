//
//  ModelTable 2.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ModelTable2: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var provider: Provider

    @State var newModelCode: String = ""
    @State var newModelName: String = ""
    @State var supportsImage: Bool = false

    var body: some View {
        modelTable
    }
    
    @State private var selections: Set<AIModel> = []
    
    var modelTable: some View {
        Form {
            modelAdder
            
            Section("") {
                List(selection: $selections) {
                    Section(header:
                        HStack(spacing: 0) {
                            Image(systemName: "photo").frame(width: 20)
                            Text("Code").frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 17)
                            Text("Name").frame(maxWidth: .infinity, alignment: .leading)
                        }
                    ) {
                        ForEach(provider.models.sorted(by: { $0.order < $1.order }), id: \.self) { model in
                            HStack(spacing: 0) {
                                Toggle(
                                    "Image",
                                    isOn: Binding(
                                        get: { model.supportsImage },
                                        set: { model.supportsImage = $0 }
                                    ))
                                .labelsHidden()
                                .frame(width: 20, alignment: .leading)
                                
                                TextField(
                                    "Code",
                                    text: Binding(
                                        get: { model.code },
                                        set: { model.code = $0 }
                                    ))
                                .frame(maxWidth: .infinity)
                                .padding(.leading, 15)
                                
                                TextField(
                                    "Name",
                                    text: Binding(
                                        get: { model.name },
                                        set: { model.name = $0 }
                                    ))
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .onDelete(perform: deleteItems)
                        .onMove(perform: moveItems)
                    }
                }
                #if os(macOS)
                .alternatingRowBackgrounds()
                #endif
                .labelsHidden()
            }
            .padding(.top, -50)
        }
        .formStyle(.grouped)
    }
    
    private func deleteItems(at offsets: IndexSet) {
        // Create a mapping from the sorted indices to the original indices
        let sortedIndices = offsets.map { provider.sortedModels[$0].id }
        // Remove the items from the original array based on their id
        provider.models.removeAll { sortedIndices.contains($0.id) }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        var updatedModels = provider.models
        updatedModels.move(fromOffsets: source, toOffset: destination)
        
        for (index, model) in updatedModels.enumerated() {
            withAnimation {
                model.order = index
            }
        }
        
        // Update the provider's models array
        provider.models = updatedModels
    }


    var modelAdder: some View {
        Group {
            HStack {
                PresetModelAdder(provider: provider)
                
                Spacer()
                
                Button(action: addModel) {
                    Label("Add", systemImage: "plus.circle")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }
            
            HStack {
                TextField("Code ", text: $newModelCode)
                TextField("Name ", text: $newModelName)
                Toggle(isOn: $supportsImage) {
                    Image(systemName: "photo")
                }
                .help("Supports Image")
                #if os(macOS)
                .toggleStyle(.checkbox)
                #endif

            }
        }
    }
    
    private func addModel() {
        if newModelCode.isEmpty || newModelName.isEmpty {
            return
        }

        let model = AIModel(
            code: newModelCode, name: newModelName, provider: provider, supportsImage: supportsImage, order: provider.models.count)
        
        provider.models.append(model)

        supportsImage = false
        newModelCode = ""
        newModelName = ""
    }
    
//    func deleteSelectedModels() {
//        provider.models.removeAll(where: { selection.contains($0.id) })
//        selection.removeAll()
//    }
}

#Preview {
    let provider = Provider.factory(type: .openai)

    ModelTable2(provider: provider)
        .modelContainer(for: Provider.self, inMemory: true)
}
