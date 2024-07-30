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
        NavigationStack {
            Form {
                Section(header: Text(modelType.rawValue.capitalized)) {
                    TextField("Code", text: $newModelCode)
                    TextField("Name", text: $newModelName)
                }
            }
            #if !os(macOS)
                        .navigationTitle("Add Model")
                        .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    addButton
                }
            }
            #endif
            .formStyle(.grouped)
            
            #if os(macOS)
            HStack {
                Spacer()
                
                cancelButton
                
                addButton
                .keyboardShortcut(.defaultAction)
            }
            .padding()
            #endif
        }

    }
    
    private var addButton: some View {
        Button("Add") {
            addModel()
        }
        .disabled(newModelCode.isEmpty || newModelName.isEmpty)
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    private func addModel() {
        if newModelCode.isEmpty || newModelName.isEmpty {
            return
        }

        let model = AIModel(
            code: newModelCode, name: newModelName, provider: provider, modelType: modelType, order: 0)
        
        for model in provider.models {
            model.order += 1
        }
        
        provider.models.append(model)
        
        dismiss()
    }
}

#Preview {
    ModelAdder(provider: Provider.factory(type: .openai), modelType: .chat)
}
