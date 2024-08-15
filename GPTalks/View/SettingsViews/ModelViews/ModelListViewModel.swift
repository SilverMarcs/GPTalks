//
//  ModelListViewModel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/07/2024.
//

import SwiftUI
import SwiftData

// MARK: - ViewModel
extension ModelListView {    
    func refreshModels() {
        isRefreshing = true
        Task { @MainActor in
            await provider.refreshModels()
            isRefreshing = false
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        let sortedModels = models.sorted(by: { $0.order < $1.order })
        let modelsToDelete = offsets.map { sortedModels[$0] }
        let sortedIndices = modelsToDelete.map { $0.id }
        
        switch modelType {
        case .chat:
            provider.chatModels.removeAll { sortedIndices.contains($0.id) }
        case .image:
            provider.imageModels.removeAll { sortedIndices.contains($0.id) }
        }
        
        for model in modelsToDelete {
            model.modelContext?.delete(model)
        }
        
        reorderModels()
    }

    func deleteSelectedModels() {
        switch modelType {
        case .chat:
            provider.chatModels.removeAll { selections.contains($0) }
        case .image:
            provider.imageModels.removeAll { selections.contains($0) }
        }
        
        for model in selections {
            model.modelContext?.delete(model)
        }
        
        selections.removeAll()
        reorderModels()
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        var sortedModels = models.sorted(by: { $0.order < $1.order })
        sortedModels.move(fromOffsets: source, toOffset: destination)
        
        reorderModels(sortedModels)
    }

    func reorderModels(_ customOrder: [AIModel]? = nil) {
        let modelsToReorder = customOrder ?? models
        let enabledModels = modelsToReorder.filter { $0.isEnabled }
        let disabledModels = modelsToReorder.filter { !$0.isEnabled }
        
        let reorderedModels = enabledModels + disabledModels
        
        for (index, model) in reorderedModels.enumerated() {
            withAnimation {
                model.order = index
            }
        }
        
        switch modelType {
        case .chat:
            provider.chatModels = reorderedModels.compactMap { $0 }
        case .image:
            provider.imageModels = reorderedModels.compactMap { $0 }
        }
    }
    
    func toggleModelType(for models: [AIModel]) {
        for model in models {
            if model.modelType == .chat {
                model.modelType = .image
            } else {
                model.modelType = .chat
            }
        }
    }
    
    func toggleEnabled(for models: [AIModel]) {
        for model in models {
            model.isEnabled.toggle()
        }
    }
}
