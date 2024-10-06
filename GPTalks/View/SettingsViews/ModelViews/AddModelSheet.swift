//
//  AddModelSheet.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/10/2024.
//

import SwiftUI

struct AddModelSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var chatModels: [ChatModel]
    @Binding var imageModels: [ImageModel]
    
    @State private var modelName: String = ""
    @State private var modelCode: String = ""
    @State private var isImageModel: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Model Name", text: $modelName)
                TextField("Model Code", text: $modelCode)
                Toggle("Is Image Model", isOn: $isImageModel)
            }
            .formStyle(.grouped)
            .navigationTitle("Add New Model")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if isImageModel {
                            imageModels.append(ImageModel(code: modelCode, name: modelName))
                        } else {
                            chatModels.append(ChatModel(code: modelCode, name: modelName))
                        }
                        dismiss()
                    }
                    .disabled(modelName.isEmpty || modelCode.isEmpty)
                }
            }
        }
    }
}
