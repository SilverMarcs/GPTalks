//
//  ModelSelectionSheet.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/10/2024.
//

import SwiftUI

struct ModelSelectionSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var refreshedModels: [ChatModel]
    var onAddToChatModels: ([ChatModel]) -> Void
    var onAddToImageModels: ([ChatModel]) -> Void

    @State private var selectedChatModels: Set<ChatModel> = []
    @State private var selectedImageModels: Set<ChatModel> = []

    var body: some View {
        NavigationStack {
            List(refreshedModels, id: \.code) { model in
                HStack {
                    Text(model.name)
                    Spacer()
                    Button(action: {
                        toggleSelection(for: model, in: &selectedChatModels)
                    }) {
                        Image(systemName: "message")
                            .foregroundStyle(selectedChatModels.contains(model) ? .green : .gray)
                    }
                    Button(action: {
                        toggleSelection(for: model, in: &selectedImageModels)
                    }) {
                        Image(systemName: "photo")
                            .foregroundStyle(selectedImageModels.contains(model) ? .indigo : .gray)
                    }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack {
                    Text("Select models")
                        .bold()
                    
                    Spacer()
                    
                    Button("Save") {
                        onAddToChatModels(Array(selectedChatModels))
                        onAddToImageModels(Array(selectedImageModels))
                        dismiss()
                    }
                }
                .padding(10)
                .background(.regularMaterial)
            }
        }
        #if os(macOS)
        .frame(height: 400)
        #endif
    }

    private func toggleSelection(for model: ChatModel, in set: inout Set<ChatModel>) {
        if set.contains(model) {
            set.remove(model)
        } else {
            set.insert(model)
        }
    }
}
