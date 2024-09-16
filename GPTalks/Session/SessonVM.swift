//
//  SessonVM.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData
import SwiftUI
import Observation

@Observable class SessionVM {
    var selections: Set<Session> = []
    var imageSelections: Set<ImageSession> = []
    
    var searchText: String = ""
    
    var state: ListState = .chats
    
    enum ListState: String, CaseIterable {
        case chats
        case images
        
        var shortcut: KeyEquivalent {
            switch self {
            case .chats:
                return "c"
            case .images:
                return "i"
            }
        }
        
        var label: String {
            switch self {
            case .chats:
                return "Chat Sessions"
            case .images:
                return "Image Generations"
            }
        }
    }
}
