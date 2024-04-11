//
//  MacInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024..
//

import PDFKit
import PhotosUI
import QuickLook
import SwiftUI

#if os(macOS)
struct MacInputView: View {
    @Environment(DialogueViewModel.self) private var viewModel
    
    @Bindable var session: DialogueSession
    
    @State private var importingImage = false
    @State private var importingAudio = false
    @State private var showMore = false
    
    @State var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CustomImportedImagesView(session: session)
            CustomPDFViewer(session: session)
            CustomAudioPreviewer(session: session)
            
            HStack(alignment: .bottom, spacing: 12) {
                Group {
                    if session.isEditing {
                        stopEditing
                    }
                    
                    moreOptions
                    
                    if showMore {
                        CustomImagePickerView(session: session, showMore: $showMore)
                        CustomPDFPickerView(session: session, showMore: $showMore, imageSize: 25, padding: 7)
                        CustomAudioPickerView(session: session, showMore: $showMore)
                    }
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
        }
        .onChange(of: session.input) {
            if session.input.count > 3 {
                showMore = false
            }
        }
        .animation(.default, value: session.inputImages)
        .animation(.default, value: session.editingImages)
        .animation(.default, value: session.inputPDFPath)
        .animation(.default, value: session.editingPDFPath)
        .animation(.default, value: session.inputAudioPath)
        .animation(.default, value: session.editingAudioPath)
//        .animation(.default, value: session.input)
//        .animation(.default, value: session.editingMessage)
        .animation(.default, value: session.isEditing)
        .animation(.default, value: showMore)
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.top, verticalPadding - 2)
        .padding(.bottom, verticalPadding + 2)
    }
    
    var moreOptions: some View {
        Button {
            showMore.toggle()
        } label: {
            Image(systemName: "plus")
                .resizable()
                .inputImageStyle(padding: 6, imageSize: imageSize)
                .rotationEffect(.degrees(showMore ? 45 : 0))
                .animation(.default, value: showMore)
        }
    }
    
    var stopEditing: some View {
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
   
    private var verticalPadding: CGFloat {
        13
    }
    
    private var imageSize: CGFloat {
        25
    }
}

#endif
