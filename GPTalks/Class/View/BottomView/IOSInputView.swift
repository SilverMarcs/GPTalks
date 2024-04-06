//
//  IOSInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

#if !os(macOS)
import SwiftUI
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
            if !session.inputImages.isEmpty || !session.editingImages.isEmpty {
                if session.isEditing {
                    ImportedImagesView(images: $session.editingImages) { index in
                        session.editingImages.remove(at: index)
                    }
                } else {
                    ImportedImagesView(images: $session.inputImages) { index in
                        session.inputImages.remove(at: index)
                    }
                }
            }

            HStack(alignment: .bottom, spacing: 12) {
                
                
                if session.isEditing {
                    stopEditing
                }
                
                MoreOptions
                
                if showMore {
                    addImage
                    resetContext
                }
                
                if session.isEditing {
                    IOSTextField(input: $session.editingMessage, isReplying: session.isReplying, focused: _focused) {
                        focused = false
                        
                        Task { @MainActor in
                            selectedItems = []
                            await session.edit()
                        }
                        
                    } stop: {
                        session.stopStreaming()
                    }
                } else {
                    IOSTextField(input: $session.input, isReplying: session.isReplying, focused: _focused) {
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
        .padding(.vertical, verticalPadding + 2)
    }
    

    
    var resetContext: some View {
        Button {
            showMore = false
            session.resetContext()
        } label: {
            Image(systemName: "eraser.fill")
                .resizable()
                .inputImageStyle(padding: 9, imageSize: imageSize + 5)
        }
        .padding(.top, -1)
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
    
    var stopEditing: some View {
        Button {
            session.resetIsEditing()
        } label: {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .padding(10)
                .fontWeight(.semibold)
                .background(.red)
                .foregroundStyle(.ultraThickMaterial)
                .clipShape(Circle())
                .frame(width: imageSize + 4, height: imageSize + 4)
                .rotationEffect(.degrees(45))
        }
    }
    
    var addImage: some View {
        Button {
            importingImage = true
            showMore = false
        } label: {
            Image(systemName: "photo")
                .resizable()
                .inputImageStyle(padding: 11, imageSize: imageSize + 9)
     
        }
        .offset(y: 2)
        .padding(.top, -2)
    }
    
    var MoreOptions: some View {
        Button {
            showMore.toggle()
        } label: {
            Image(systemName: "plus")
                .resizable()
                .inputImageStyle(padding: 10, imageSize: imageSize + 6)
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
                            if session.isEditing {
                                session.editingImages.append(image)
                            } else {
                                session.inputImages.append(image)
                            }
                        }
                    }
                }
                selectedItems = [] // Reset selection
            }
        }
        .padding(20) // Increase tappable area
        .padding(-20) // Cancel out visual expansion
        .background(Color.clear)
//        .offset(y: -1)
    }

    private var verticalPadding: CGFloat {
        return 7
    }

    private var imageSize: CGFloat {
        31
    }
}
#endif
