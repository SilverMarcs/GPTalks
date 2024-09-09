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
    @AppStorage("quickProvider") var quickProvider: String?
    
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
}
