//
//  ModelTable 2.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//


import SwiftUI

#if os(macOS)
struct ModelTable: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var provider: Provider

    @State var newModelCode: String = ""
    @State var newModelName: String = ""
    @State var supportsImage: Bool = false

    var body: some View {
        modelTable
    }
    
    @State private var selection: Set<AIModel.ID> = []
    
    var modelTable: some View {
        Form {
            modelAdder
            
            Section("") {
                Table(provider.models.sorted { $0.supportsImage && !$1.supportsImage }, selection: $selection) {
                    TableColumn("Image") { model in
                        Toggle(
                            "Image",
                            isOn: Binding(
                                get: { model.supportsImage },
                                set: { model.supportsImage = $0 }
                            ))
                        .labelsHidden()
                    }
                    .width(max: 37)
                    
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
                }
                .labelsHidden()
                .onDeleteCommand(perform: deleteSelectedModels)
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
                .toggleStyle(.checkbox)
            }
        }
    }
    
    private func addModel() {
        if newModelCode.isEmpty || newModelName.isEmpty {
            return
        }

        let model = AIModel(
            code: newModelCode, name: newModelName, provider: provider, supportsImage: supportsImage)
        
        withAnimation {
            provider.models.append(model)
        }

        supportsImage = false
        newModelCode = ""
        newModelName = ""
    }
    
    func deleteSelectedModels() {
        provider.models.removeAll(where: { selection.contains($0.id) })
        withAnimation {
            selection.removeAll()
        }
    }
}

#Preview {
    let provider = Provider.factory(type: .openai)

    ModelTable(provider: provider)
        .modelContainer(for: Provider.self, inMemory: true)
}
#endif
