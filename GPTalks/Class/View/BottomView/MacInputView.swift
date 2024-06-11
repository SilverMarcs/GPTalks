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
            .offset(y: -1.15)
            
            CustomTextEditorView(session: session)
            
            Group {
                if session.isReplying {
                    StopButton(size: imageSize) { session.stopStreaming() }
                } else {
                    SendButton(size: imageSize) { Task { @MainActor in viewModel.moveUpChat(session: session); await session.sendAppropriate() } }
                }
            }
            .offset(y: -1.15)
        }
        .animation(.default, value: session.inputImages)
        .animation(.default, value: session.editingImages)
        .animation(.default, value: session.inputPDFPath)
        .animation(.default, value: session.editingPDFPath)
        .animation(.default, value: session.inputAudioPath)
        .animation(.default, value: session.editingAudioPath)
        .animation(.default, value: session.isEditing)
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.top, verticalPadding - 2)
        .padding(.bottom, verticalPadding + 2)
        .generalizedFileImporter(isPresented: $importingFiles) { urls in
            handleSelectedFiles(urls)
        }
    }
    
    var selectFilesButton: some View {
        Button {
            importingFiles = true
        } label: {
            Image(systemName: "plus")
                .resizable()
                .inputImageStyle(padding: 6, imageSize: imageSize)
        }
    }
       
    func handleSelectedFiles(_ urls: [URL]) {
        for url in urls {
            if let type = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType {
                if type.conforms(to: .audio) {
                    handleAudioFile(url)
                } else if type.conforms(to: .pdf) {
                    handlePDFFile(url)
                } else if type.conforms(to: .image) {
                    handleImageFile(url)
                }
            }
        }
    }
   
    func handleAudioFile(_ url: URL) {
        var currentAudioPath: Binding<String> {
            session.isEditing ? $session.editingAudioPath : $session.inputAudioPath
        }
       
        currentAudioPath.wrappedValue = url.absoluteString
        session.configuration.useTranscribe = true
    }
   
    func handlePDFFile(_ url: URL) {
        var currentPDFPath: Binding<String> {
            session.isEditing ? $session.editingPDFPath : $session.inputPDFPath
        }
       
        currentPDFPath.wrappedValue = url.absoluteString
        session.configuration.useExtractPdf = true
    }
   
    func handleImageFile(_ url: URL) {
        var currentImages: Binding<[PlatformImage]> {
            session.isEditing ? $session.editingImages : $session.inputImages
        }
       
        if let image = NSImage(contentsOf: url) {
            currentImages.wrappedValue.append(image)
            if ![Model.gpt4t, Model.gpt4o].contains(session.configuration.model) {
                session.configuration.useVision = true
            }
        }
    }
    
    @ViewBuilder
    var editControls: some View {
        if session.isEditing {
            Button {
                session.resetIsEditing()
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .inputImageStyle(padding: 6, imageSize: imageSize, color: .red)
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
