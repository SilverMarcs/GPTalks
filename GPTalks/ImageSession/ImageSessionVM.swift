//
//  ImageSessionVM.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/07/2024.
//

import SwiftUI
import SwiftData
import Foundation

//MARK: Image Session
extension SessionVM {
    public var activeImageSession: ImageSession? {
        guard imageSelections.count == 1 else { return nil }
        return imageSelections.first
    }
    
    func sendImageGenerationRequest() {
        guard let session = activeImageSession else { return }
        Task {
            await session.send()
        }
    }
    
    func deleteLastImageGeneration() {
        guard let session = activeImageSession else { return }
        if let last = session.imageGenerations.last {
            last.deleteSelf()
        }
    }
    
    @discardableResult
    func addImageSession(modelContext: ModelContext, provider: Provider? = nil) -> ImageSession? {
        let config: ImageConfig
        
        if let providedProvider = provider {
            // Use the provided provider
            config = ImageConfig(provider: providedProvider)
        } else {
            // Use the default provider
            let fetchProviders = FetchDescriptor<Provider>()
            let fetchedProviders = try! modelContext.fetch(fetchProviders)
            
            guard let defaultProvider = ProviderManager.shared.getImageProvider(providers: fetchedProviders) else {
                return nil
            }
            
            config = ImageConfig(provider: defaultProvider)
        }
        
        let newItem = ImageSession(config: config)
        
        var fetchSessions = FetchDescriptor<ImageSession>()
        fetchSessions.sortBy = [SortDescriptor(\.order)]
        let fetchedSessions = try! modelContext.fetch(fetchSessions)
        
        for session in fetchedSessions {
            session.order += 1
        }
        
        newItem.order = 0
        modelContext.insert(newItem)
        try? modelContext.save()
        
        self.imageSelections = [newItem]
        
        return newItem
    }
}
