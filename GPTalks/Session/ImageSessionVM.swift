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
    
    func addimageSession(imageSessions: [ImageSession], providers: [Provider], modelContext: ModelContext) {
        let provider: Provider
        if let defaultProvider = providerManager.getDefault(providers: providers) {
            provider = defaultProvider
        } else if let firstProvider = providers.first {
            provider = firstProvider
        } else {
            return
        }
        
        let newItem = ImageSession(config: ImageConfig(provider: provider, model: provider.imageModel))
        
        withAnimation {
            // Increment the order of all existing items
            for session in imageSessions {
                session.order += 1
            }
            
            newItem.order = 0  // Set the new item's order to 0 (top of the list)
            modelContext.insert(newItem)
            self.imageSelections = [newItem]
        }
        
        try? modelContext.save()
    }
}

