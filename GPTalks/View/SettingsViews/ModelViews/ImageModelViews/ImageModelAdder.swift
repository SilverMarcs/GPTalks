//
//  ImageModelAdder.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/07/2024.
//

import SwiftUI

struct ImageModelAdder: View {
    @Environment(\.dismiss) var dismiss
    var provider: Provider
    
    @State var newModelCode: String = ""
    @State var newModelName: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Chat") {
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

        let model = ChatModel(
            code: newModelCode, name: newModelName)
        
        provider.chatModels.insert(model, at: 0)
        
        dismiss()
    }
}

#Preview {
    ChatModelAdder(provider: .openAIProvider)
}
