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
//    var normalImagePaths: [String] = []
//    var tempNormalImagePaths: [String] = []
    
    var editingPrompt: String = ""
//    var editingImagePaths: [String] = []
    var editingDataFiles: [TypedData] = []
    
    var editingIndex: Int?
    
    // simpler inputs
    var normalDataFiles: [TypedData] = []
    var tempNormalDataFiles: [TypedData] = []
    
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
    
//    var imagePaths: [String] {
//        get {
//            switch state {
//            case .normal:
//                normalImagePaths
//            case .editing:
//                editingImagePaths
//            }
//        }
//        set {
//            switch state {
//            case .normal:
//                normalImagePaths = newValue
//            case .editing:
//                editingImagePaths = newValue
//            }
//        }
//    }
    
    var dataFiles: [TypedData] {
        get {
            switch state {
            case .normal:
                normalDataFiles
            case .editing:
                editingDataFiles
            }
        }
        set {
            switch state {
            case .normal:
                normalDataFiles = newValue
            case .editing:
                editingDataFiles = newValue
            }
        }
    }
    
    func setupEditing(for group: ConversationGroup) {
        tempNormalPrompt = normalPrompt
//        tempNormalImagePaths = normalImagePaths
        tempNormalDataFiles = normalDataFiles
        
        state = .editing
        prompt = group.activeConversation.content
//        imagePaths = group.activeConversation.imagePaths
        dataFiles = group.activeConversation.dataFiles
        editingIndex = group.session?.groups.firstIndex(of: group)
    }
    
    func resetEditing() {
        state = .normal
        editingIndex = nil
        prompt = tempNormalPrompt ?? ""
    }
    
    func reset() {
        prompt = ""
        dataFiles = []
//        imagePaths = []
    }
}


// MARK: Pasting
extension InputManager {
    func handlePaste() {
//        #if os(macOS)
//        let pasteboard = NSPasteboard.general
//        if let image = NSImage(pasteboard: pasteboard) {
//            if let savedPath = image.save() {
//                imagePaths.append(savedPath)
//            }
//        }
//        #else
//        let pasteboard = UIPasteboard.general
//        if let image = pasteboard.image {
//            if let savedPath = image.save() {
//                imagePaths.append(savedPath)
//            }
//        }
//        #endif
    }
    
//    func handleImageDrop(_ providers: [NSItemProvider]) {
//        for provider in providers {
//            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
//                provider.loadObject(ofClass: PlatformImage.self) { [weak self] image, error in
//                    guard let self = self, let image = image as? PlatformImage else {
//                        print("Could not load image: \(String(describing: error))")
//                        return
//                    }
//                    
//                    DispatchQueue.main.async {
//                        if let savedPath = image.save() {
//                            if !self.imagePaths.contains(savedPath) {
//                                self.imagePaths.append(savedPath)
//                            }
//                        } else {
//                            print("Failed to save image to disk")
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func handleDrop(_ providers: [NSItemProvider], supportedTypes: [UTType]) -> Bool {
//        let group = DispatchGroup()
//        var didDrop = false
//        
//        for provider in providers {
//            for type in supportedTypes {
//                if provider.hasItemConformingToTypeIdentifier(type.identifier) {
//                    group.enter()
//                    provider.loadFileRepresentation(forTypeIdentifier: type.identifier) { [weak self] url, error in
//                        defer { group.leave() }
//                        guard let self = self, let url = url else {
//                            print("Could not load file: \(String(describing: error))")
//                            return
//                        }
//                        
//                        if let data = try? Data(contentsOf: url) {
//                            let fileName = url.lastPathComponent
//                            let fileSize = ((try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0).formatFileSize()
//                            let fileExtension = url.pathExtension.lowercased()
//                            
//                            let typedData = TypedData(
//                                data: data,
//                                fileType: type,
//                                fileName: fileName,
//                                fileSize: fileSize,
//                                fileExtension: fileExtension
//                            )
//                            DispatchQueue.main.async {
//                                self.normalDataFiles.append(typedData)
//                                didDrop = true
//                            }
//                        }
//                    }
//                    break // Move to the next provider after finding a match
//                }
//            }
//        }
//        
//        group.wait()
//        return didDrop
        return true
    }
}
