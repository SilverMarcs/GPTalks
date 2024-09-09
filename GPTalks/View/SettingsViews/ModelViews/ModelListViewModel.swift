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
        let models = provider.models(for: type)
        let sortedModels = models.sorted(by: { $0.order < $1.order })
        let modelsToDelete = offsets.map { sortedModels[$0] }
        
        for model in modelsToDelete {
            provider.removeModel(model, for: type)
            model.modelContext?.delete(model)
        }
        
        reorderModels()
    }

    func deleteSelectedModels() {
        for model in selections {
            provider.removeModel(model, for: type)
            model.modelContext?.delete(model)
        }
        
        selections.removeAll()
        reorderModels()
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        let models = provider.models(for: type)
        var sortedModels = models.sorted(by: { $0.order < $1.order })
        sortedModels.move(fromOffsets: source, toOffset: destination)
        
        reorderModels(sortedModels)
    }

    func reorderModels(_ customOrder: [AIModel]? = nil) {
        let models = provider.models(for: type)
        let modelsToReorder = customOrder ?? models
        let enabledModels = modelsToReorder.filter { $0.isEnabled }
        let disabledModels = modelsToReorder.filter { !$0.isEnabled }
        
        let reorderedModels = enabledModels + disabledModels
        
        for (index, model) in reorderedModels.enumerated() {
            withAnimation {
                model.order = index
            }
        }
        
        provider.setModels(reorderedModels, for: type)
    }

    func toggleModelType(for models: [AIModel]) {
        for model in models {
            let newType: ModelType = model.type == .chat ? .image : .chat
            provider.removeModel(model, for: type)
            model.type = newType
            provider.addModel(model, for: newType)
        }
    }
    func toggleEnabled(for models: [AIModel]) {
        for model in models {
            model.isEnabled.toggle()
        }
    }
}
