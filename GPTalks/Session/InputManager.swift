//
//  InputManager.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI

enum InputState {
    case normal
    case editing
}

@Observable class InputManager {
    var state: InputState = .normal
    
    var inputPrompt: String = ""
    var editingPrompt: String = ""
    
    var editingIndex: Int?
    
    init() {
        
    }
    
    var prompt: String {
        get {
            switch state {
            case .normal:
                inputPrompt
            case .editing:
                editingPrompt
            }
        }
        set {
            switch state {
            case .normal:
                inputPrompt = newValue
            case .editing:
                editingPrompt = newValue
            }
        }
    }
    
    func setupEditing(for group: ConversationGroup) {
        state = .editing
        prompt = group.activeConversation.content
        editingIndex = group.session?.groups.firstIndex(of: group)
    }
    
    func cancelEditing() {
        state = .normal
        prompt = ""
    }
    
    func reset() {
        prompt = ""
    }
}
