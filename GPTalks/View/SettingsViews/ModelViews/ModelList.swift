//
//  ModelList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//


import SwiftUI

#if !os(macOS)
struct ModelList: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var provider: Provider

    @State var newModelCode: String = ""
    @State var newModelName: String = ""
    @State var supportsImage: Bool = false

    var body: some View {
        List {
            Section ("Models") {
                ForEach(provider.models, id: \.self) { model in
                    ModelRow(model: model)
                }
            }
            
            Section ("Add New"){
                Toggle("Supports Image", isOn: $supportsImage)
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
                PresetModelAdder(provider: provider)
            }
        }
    }

    private func addModel() {
        if newModelCode.isEmpty || newModelName.isEmpty {
            return
        }

        let model = AIModel(
            code: newModelCode, name: newModelName, provider: provider, supportsImage: supportsImage)
        
        provider.models.append(model)

        supportsImage = false
        newModelCode = ""
        newModelName = ""
    }
}

#Preview {
    let provider = Provider.factory(type: .openai)

    ModelList(provider: provider)
        .modelContainer(for: Provider.self, inMemory: true)
}
#endif
