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
        HStack(alignment: .bottom, spacing: 12) {
            Group {
                moreOptions
                
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
        .animation(.default, value: session.isEditing)
        .animation(.default, value: showMore)
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.top, verticalPadding - 2)
        .padding(.bottom, verticalPadding + 2)
    }
    
    var moreOptions: some View {
        toggleButton
            .overlay(
                Group {
                    if showMore {
                        VStack {
                            CustomAudioPickerView(session: session, showMore: $showMore)
                            CustomPDFPickerView(session: session, showMore: $showMore, imageSize: 25, padding: 7)
                            CustomImagePickerView(session: session, showMore: $showMore)
                            toggleButton
                        }
                        .padding(5)
                        .background(.thickMaterial)
                        .cornerRadius(15)
//                        .roundedRectangleOverlay(opacity: 0.5)
//                        .shadow(radius: 2, y: 1)
                        .offset(x: 0, y: 5) // Adjust this value as needed
                    }
                }, alignment: .bottom
            )
    }
    
    @ViewBuilder
    var toggleButton: some View {
        var degree: Double {
            showMore ? 45 : 0
        }
        
        Button {
            withAnimation {
                showMore.toggle()
            }
        } label: {
            Image(systemName: "plus")
                .resizable()
                .inputImageStyle(padding: 6, imageSize: imageSize)
                .rotationEffect(.degrees(degree))
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
