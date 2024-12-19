//
//  MacInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024..
//

import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
struct MacInputView: View {
    @Environment(DialogueViewModel.self) private var viewModel
    
    @Bindable var session: DialogueSession
    
    @State private var importingFiles = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            Group {
                selectFilesButton
                
                editControls
            }
            .offset(y: -2)
            
            CustomTextEditorView(session: session)
            
            Group {
                if session.isReplying {
                    StopButton(size: imageSize - 1) { session.stopStreaming() }
                } else {
                    SendButton(size: imageSize - 1) { Task { @MainActor in viewModel.moveUpChat(session: session); await session.sendAppropriate() } }
                }
            }
            .offset(y: -2)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.top, verticalPadding - 2)
        .padding(.bottom, verticalPadding + 2)
        .imageFileImporter(isPresented: $importingFiles) { urls in
            handleSelectedFiles(urls)
        }
    }
    
    var selectFilesButton: some View {
        Button {
            importingFiles = true
        } label: {
            Image(systemName: "plus")
                .resizable()
                .inputImageStyle(padding: 6, imageSize: imageSize - 1)
        }
    }
       
    func handleSelectedFiles(_ urls: [URL]) {
        for url in urls {
            if let type = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType {
                if type.conforms(to: .image) {
                    handleImageFile(url)
                }
            }
        }
    }
    
    func handleImageFile(_ url: URL) {
        var currentImages: Binding<[String]> {
            session.isEditing ? $session.editingImages : $session.inputImages
        }
        
        currentImages.wrappedValue.append(url.absoluteString)
    }
    
    @ViewBuilder
    var editControls: some View {
        if session.isEditing {
            Button {
                session.resetIsEditing()
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .inputImageStyle(padding: 6, imageSize: imageSize - 1, color: .red)
                    .rotationEffect(.degrees(45))
            }
            .keyboardShortcut(.cancelAction)
        }
    }
   
    private var verticalPadding: CGFloat {
        13
    }
    
    private var imageSize: CGFloat {
        25
    }
}

#endif
