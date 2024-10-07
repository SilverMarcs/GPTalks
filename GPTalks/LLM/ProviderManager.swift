//
//  ProviderManager.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/07/2024.
//

import Foundation
import SwiftUI

class ProviderManager: ObservableObject {
    static let shared = ProviderManager()
    
    @AppStorage("defaultProvider") var defaultProvider: String?
    @AppStorage("imageProvider") var imageProvider: String?
    @AppStorage("quickProvider") var quickProvider: String?
    @AppStorage("toolImageProvider") var toolImageProvider: String?
    @AppStorage("toolSTTProvider") var toolSTTProvider: String?
    
    private init() {}
    
    func getDefault(providers: [Provider]) -> Provider? {
        defaultProvider.flatMap { id in
            providers.first { $0.id.uuidString == id }
        }
    }
    
    func getQuickProvider(providers: [Provider]) -> Provider? {
        quickProvider.flatMap { id in
            providers.first { $0.id.uuidString == id }
        }
    }
    
    func getImageProvider(providers: [Provider]) -> Provider? {
        imageProvider.flatMap { id in
            providers.first { $0.id.uuidString == id }
        }
    }
    
    func getToolImageProvider(providers: [Provider]) -> Provider? {
        toolImageProvider.flatMap { id in
            providers.first { $0.id.uuidString == id }
        }
    }
    
    func getToolSTTProvider(providers: [Provider]) -> Provider? {
        toolSTTProvider.flatMap { id in
            providers.first { $0.id.uuidString == id }
        }
    }
}
