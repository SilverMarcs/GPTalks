//
//  ModelAdder.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/10/2024.
//

import SwiftUI

struct ModelAdder: View {
    @Environment(\.dismiss) private var dismiss
    var provider: Provider
    
    @State private var modelName: String = ""
    @State private var modelCode: String = ""
    @State private var selectedModelType: ModelType = .chat

    var body: some View {
        NavigationStack {
            Form {
                TextField("Model Name", text: $modelName)
                TextField("Model Code", text: $modelCode)
                Picker("Model Type", selection: $selectedModelType) {
                    ForEach(ModelType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Add Model")
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
        provider.models.append(.init(code: modelCode, name: modelName, type: selectedModelType))
    }
}
