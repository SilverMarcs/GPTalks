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
    
    var normalPrompt: String = ""
    var tempNormalPrompt: String? = ""
    var normalImagePaths: [String] = []
    var tempNormalImagePaths: [String] = []
    
    var editingPrompt: String = ""
    var editingIndex: Int?
    var editingImagePaths: [String] = []
    
    init() { }
    
    var prompt: String {
        get {
            switch state {
            case .normal:
                normalPrompt
            case .editing:
                editingPrompt
            }
        }
        set {
            switch state {
            case .normal:
                normalPrompt = newValue
            case .editing:
                editingPrompt = newValue
            }
        }
    }
    
    var imagePaths: [String] {
        get {
            switch state {
            case .normal:
                normalImagePaths
            case .editing:
                editingImagePaths
            }
        }
        set {
            switch state {
            case .normal:
                normalImagePaths = newValue
            case .editing:
                editingImagePaths = newValue
            }
        }
    }
    
    func setupEditing(for group: ConversationGroup) {
        tempNormalPrompt = normalPrompt
        tempNormalImagePaths = normalImagePaths
        
        state = .editing
        prompt = group.activeConversation.content
        imagePaths = group.activeConversation.imagePaths
        editingIndex = group.session?.groups.firstIndex(of: group)
    }
    
    func resetEditing() {
        state = .normal
        editingIndex = nil
        prompt = tempNormalPrompt ?? ""
    }
    
    func reset() {
        prompt = ""
    }
}
