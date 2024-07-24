//
//  ModelTable.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI

struct ModelTable: View {
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
                        ModelCollection(provider: provider)
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

    ModelTable(provider: provider)
        .modelContainer(for: Provider.self, inMemory: true)
}
