//
//  InputManager.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import UniformTypeIdentifiers

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
    
    #if os(macOS)
    private var localEventMonitor: Any?
    #endif
    
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
        imagePaths = []
    }
}


// MARK: Pasting
extension InputManager {
    func handlePaste() {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        if let image = NSImage(pasteboard: pasteboard) {
            if let savedPath = image.save() {
                imagePaths.append(savedPath)
            }
        }
        #else
        let pasteboard = UIPasteboard.general
        if let image = pasteboard.image {
            if let savedPath = image.save() {
                imagePaths.append(savedPath)
            }
        }
        #endif
    }
    
    func handleImageDrop(_ providers: [NSItemProvider]) {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadObject(ofClass: PlatformImage.self) { [weak self] image, error in
                    guard let self = self, let image = image as? PlatformImage else {
                        print("Could not load image: \(String(describing: error))")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if let savedPath = image.save() {
                            if !self.imagePaths.contains(savedPath) {
                                self.imagePaths.append(savedPath)
                            }
                        } else {
                            print("Failed to save image to disk")
                        }
                    }
                }
            }
        }
    }
}
