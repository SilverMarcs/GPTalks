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
    var type: ModelType
    
    @State var newModelCode: String = ""
    @State var newModelName: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(type.rawValue.capitalized)) {
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
            code: newModelCode, name: newModelName, type: type, order: 0)
        
        if type == .chat {
            for model in provider.chatModels {
                model.order += 1
            }
            provider.chatModels.insert(model, at: 0)
        } else if type == .image {
            for model in provider.imageModels {
                model.order += 1
            }
            provider.imageModels.insert(model, at: 0)
        }
        
        dismiss()
    }
}

#Preview {
    ModelAdder(provider: .openAIProvider, type: .chat)
}
