//
//  ModelAdder.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/07/2024.
//

import SwiftUI

struct ModelAdder: View {
    @Environment(\.dismiss) var dismiss
    var provider: Provider
    var modelType: ModelType
    
    @State var newModelCode: String = ""
    @State var newModelName: String = ""
    
    var body: some View {
        Form {
            Section(header: Text(modelType.rawValue.capitalized)) {
                TextField("Code", text: $newModelCode)
                TextField("Name", text: $newModelName)
            }
            
            Section {
                Button(action: addModel) {
                    Label("Add", systemImage: "plus")
                        .foregroundStyle(.accent)
                }
                .contentShape(Rectangle())
                .buttonStyle(.plain)
            }
        }
        .formStyle(.grouped)
    }
    
    private func addModel() {
        if newModelCode.isEmpty || newModelName.isEmpty {
            return
        }

        let model = AIModel(
            code: newModelCode, name: newModelName, provider: provider, modelType: modelType)
        
        provider.models.append(model)
        
        dismiss()
    }
}

#Preview {
    ModelAdder(provider: Provider.factory(type: .openai), modelType: .chat)
}
