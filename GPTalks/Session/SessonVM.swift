//
//  SessonVM.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

enum ListState: String {
    case chats
    case images
}

@Observable class SessionVM {
    var providerManager: ProviderManager
    
    init(providerManager: ProviderManager = ProviderManager.shared) {
        self.providerManager = providerManager
    }
    
    var selections: Set<Session> = []
    var imageSelections: Set<ImageSession> = []
    
    var searchText: String = ""
    
    var state: ListState = .chats
    
    #if os(macOS)
    var chatCount: Int = 12
    #else
    var chatCount: Int = .max
    #endif
}
