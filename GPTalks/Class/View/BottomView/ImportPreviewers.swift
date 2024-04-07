//
//  ImportPreviewers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/04/2024.
//

import SwiftUI

struct CustomImportedImagesView: View {
    @Bindable var session: DialogueSession
    
    private var currentImages: Binding<[PlatformImage]> {
        session.isEditing ? $session.editingImages : $session.inputImages
    }
    
    var body: some View {
        if !currentImages.wrappedValue.isEmpty {
            ImportedImagesView(images: currentImages) { index in
                currentImages.wrappedValue.remove(at: index)
            }
        }
    }
}

struct CustomPDFViewer: View {
    @Bindable var session: DialogueSession
    
    private var currentPDFPath: Binding<String> {
        session.isEditing ? $session.editingPDFPath : $session.inputPDFPath
    }
    
    var body: some View {
        if !currentPDFPath.wrappedValue.isEmpty {
            PDFViewer(pdfURL: URL(string: currentPDFPath.wrappedValue)!, removePDFAction: {
                self.currentPDFPath.wrappedValue = ""
            })
        }
    }
}

struct CustomAudioPreviewer: View {
    @Bindable var session: DialogueSession
    
    private var currentAudioPath: Binding<String> {
        session.isEditing ? $session.editingAudioPath : $session.inputAudioPath
    }
    
    var body: some View {
        if !currentAudioPath.wrappedValue.isEmpty {
            AudioPreviewer(audioURL: URL(string: currentAudioPath.wrappedValue)!, showRemoveButton: true, removeAudioAction: {
                self.currentAudioPath.wrappedValue = ""
            })
        }
    }
}

struct CustomTextEditoView: View {
    @Bindable var session: DialogueSession
    
    private var currentMessage: Binding<String> {
        session.isEditing ? $session.editingMessage : $session.input
    }
    
    var body: some View {
        MacTextEditor(input: currentMessage)
    }
}
