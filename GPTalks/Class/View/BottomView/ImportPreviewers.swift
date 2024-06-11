//
//  ImportPreviewers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/04/2024.
//

import SwiftUI

struct CustomImportedImagesView: View {
    @Bindable var session: DialogueSession
    
    private var currentImages: Binding<[String]> {
        session.isEditing ? $session.editingImages : $session.inputImages
    }
    
    var body: some View {
        ForEach(currentImages.wrappedValue, id: \.self) { image in
            ImagePreviewer(imageURL: URL(string: image)!) {
                self.currentImages.wrappedValue.removeAll(where: { $0 == image })
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

#if os(macOS)
struct CustomTextEditorView: View {
    @Bindable var session: DialogueSession
    
    private var currentMessage: Binding<String> {
        session.isEditing ? $session.editingMessage : $session.input
    }
    
    private var containsPdfOrAudio: Bool {
        return !session.inputPDFPath.isEmpty || !session.inputAudioPath.isEmpty || !session.editingPDFPath.isEmpty || !session.editingPDFPath.isEmpty
    }
    
    private var containsImage: Bool {
        return !session.inputImages.isEmpty || !session.editingImages.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if containsImage {
                ScrollView(.horizontal) {
                    HStack {
                        CustomImportedImagesView(session: session)
                    }
                    .padding(10)
                }
            }
            
            if containsPdfOrAudio {
                ScrollView(.horizontal) {
                    HStack {
                        CustomPDFViewer(session: session)
                        CustomAudioPreviewer(session: session)
                    }
                }
                .padding(10)
                .padding(.top, containsImage ? -7 : 0)
            }
            
            if containsPdfOrAudio || containsImage {
                Divider()
            }

            MacTextEditor(input: currentMessage)
        }
        .roundedRectangleOverlay()
    }
}
#else
struct CustomTextEditorView: View {
    @Bindable var session: DialogueSession
    @FocusState var focused: Bool
    var extraAction: (() -> Void)
    
    private var currentMessage: Binding<String> {
        session.isEditing ? $session.editingMessage : $session.input
    }
    
    var body: some View {
        IOSTextField(input: currentMessage, isReplying: session.isReplying, focused: _focused) {
            focused = false
            
            Task { @MainActor in
                extraAction()
                await session.sendAppropriate()
            }
            
        } stop: {
            session.stopStreaming()
        }
    }
}
#endif

struct CustomCrossButton: View {
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.background)
                .background(.primary, in: Circle())
        }
        .padding(7)
        .buttonStyle(.plain)
    }
}
