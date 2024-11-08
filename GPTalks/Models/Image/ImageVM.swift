//
//  ImageVM.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData
import Foundation

@Observable class ImageVM {
    var searchText: String = ""
    var selections: Set<ImageSession> = []
    
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public var activeImageSession: ImageSession? {
        guard selections.count == 1 else { return nil }
        return selections.first
    }
    
    func sendGenerationRequest() {
        guard let session = activeImageSession else { return }
        Task {
            await session.send()
        }
    }
    
    func deleteLastGeneration() {
        guard let session = activeImageSession else { return }
        if let last = session.imageGenerations.last {
            last.deleteSelf()
        }
    }
    
    @discardableResult
    func createNewSession(provider: Provider? = nil) -> ImageSession? {
        let config: ImageConfig
        
        if let providedProvider = provider {
            // Use the provided provider
            config = ImageConfig(prompt: "", provider: providedProvider)
        } else {
            // Use the default provider
            let fetchDefaults = FetchDescriptor<ProviderDefaults>()
            let defaults = try! modelContext.fetch(fetchDefaults)
            
            let defaultProvider = defaults.first!.imageProvider
            
            config = ImageConfig(provider: defaultProvider)
        }
        
        let newItem = ImageSession(config: config)
        modelContext.insert(newItem)
        try? modelContext.save()
        
        self.selections = [newItem]
        
        return newItem
    }
}
