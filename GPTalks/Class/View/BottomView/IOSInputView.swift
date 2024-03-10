//
//  IOSInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

#if !os(macOS)
import SwiftUI
import VisualEffectView
import PhotosUI

struct IOSInputView: View {
    @Bindable var session: DialogueSession
    
    @FocusState var focused: Bool
    
    @State private var importingImage = false
    @State private var importingAudio = false
    @State private var showMore = false
    
    @State var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !session.inputImages.isEmpty {
                ImportedImages(session: session)
            }

            HStack(spacing: 12) {
                
                MoreOptions
                
                if showMore {
                    addImage
                    regenerate
                    resetContext
                }
                
                IOSTextField(input: $session.input, isReplying: session.isReplying) {
                    focused = false
                    
                    Task { @MainActor in
                        selectedItems = []
                        await session.send()
                    }
                    
                } stop: {
                    session.stopStreaming()
                }

            }
        }
        .onChange(of: session.input) {
            if session.input.count > 3 {
                showMore = false
            }
        }
        .animation(.default, value: session.inputImages)
        .animation(.default, value: showMore)
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.top, verticalPadding)
        .padding(.bottom, verticalPadding + 2)
    }
    

    
    var resetContext: some View {
        Button {
            showMore = false
            session.resetContext()
        } label: {
            Image(systemName: "eraser")
                .resizable()
                .inputImageStyle(padding: 10, imageSize: imageSize + 3)
        }
    }
    
    var regenerate: some View {
        Button {
            showMore = false
            Task {
                await session.regenerateLastMessage()
            }
        } label: {
            Image(systemName: "arrow.2.circlepath")
                .resizable()
                .inputImageStyle(padding: 10, imageSize: imageSize + 6)
        }
    }
    
    var addImage: some View {
        Button {
            importingImage = true
            showMore = false
        } label: {
            Image(systemName: "photo")
                .resizable()
                .inputImageStyle(padding: 11, imageSize: imageSize + 7)
        }
    }
    
    var MoreOptions: some View {
        Button {
            showMore.toggle()
        } label: {
            Image(systemName: "plus")
                .resizable()
                .inputImageStyle(padding: 10, imageSize: imageSize + 3)
                .rotationEffect(.degrees(showMore ? 45 : 0))
                .animation(.default, value: showMore)
        }
        .photosPicker(
            isPresented: $importingImage,
            selection: $selectedItems,
            maxSelectionCount: 5, 
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedItems) {
            Task {
                for newItem in selectedItems {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: data) {
                            session.inputImages.append(image)
                        }
                    }
                }
                selectedItems = [] // Reset selection
            }
        }
        .padding(20) // Increase tappable area
        .padding(-20) // Cancel out visual expansion
        .background(Color.clear)
    }

    private var verticalPadding: CGFloat {
        return 7
    }

    private var imageSize: CGFloat {
        31
    }
}
#endif
