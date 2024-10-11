//
//  AddModelSheet.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/10/2024.
//

import SwiftUI

struct AddModelSheet<M: ModelType>: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var models: [M]
    
    @State private var modelName: String = ""
    @State private var modelCode: String = ""
    @State private var selectedModelType: ModelTypeOption

    init(models: Binding<[M]>) {
        self._models = models
        if M.self == ChatModel.self {
            self._selectedModelType = State(initialValue: .chat)
        } else if M.self == ImageModel.self {
            self._selectedModelType = State(initialValue: .image)
        } else if M.self == STTModel.self {
            self._selectedModelType = State(initialValue: .stt)
        } else {
            fatalError("Unsupported model type")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Model Name", text: $modelName)
                TextField("Model Code", text: $modelCode)
            }
            .formStyle(.grouped)
            .navigationTitle("Add \(selectedModelType.rawValue.capitalized) Model")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addModel()
                        dismiss()
                    }
                    .disabled(modelName.isEmpty || modelCode.isEmpty)
                }
            }
        }
    }
    
    private func addModel() {
        let newModel = M(code: modelCode, name: modelName)
        models.append(newModel)
    }
}
