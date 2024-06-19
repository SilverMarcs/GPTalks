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
            CustomImportedImagesView(session: session)
//            CustomPDFViewer(session: session)

            HStack(alignment: .bottom, spacing: 12) {
                if session.isEditing {
                    stopEditing
                }
                
                moreOptions
                
//                if showMore {
//                    addImage
//                    CustomPDFPickerView(session: session, showMore: $showMore, imageSize: imageSize, padding: 10)
//                    resetContext
//                }
                
                CustomTextEditorView(session: session, focused: _focused) {
                    selectedItems = []
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
            Image(systemName: "eraser")
                .resizable()
                .inputImageStyle(padding: 10, imageSize: imageSize)
        }
        .padding(.top, -1)
    }
    
    var stopEditing: some View {
        Button {
            session.resetIsEditing()
        } label: {
            Image(systemName: "plus")
                .resizable()
                .inputImageStyle(padding: 10, imageSize: imageSize, color: .red)
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
                .inputImageStyle(padding: 11, imageSize: imageSize)
     
        }
    }
    
    @State private var imageOpacity: Double = 1.0
    
    var moreOptions: some View {
        Image(systemName: "plus")
            .resizable()
            .inputImageStyle(padding: 10, imageSize: imageSize)
            .opacity(imageOpacity)
            .gesture(
                TapGesture()
                    .onEnded {
                        imageOpacity = 0.5
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            imageOpacity = 1.0
                        }
                        importingImage = true
                    }
                    .simultaneously(with: LongPressGesture(minimumDuration: 0.3)
                        .onChanged { _ in
                            imageOpacity = 0.5
                        }
                        .onEnded { _ in
                            imageOpacity = 1.0
                            session.resetContext()
                        }
                    )
            )
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
                            if let filePath = saveImage(image: image) {
                                if session.isEditing {
                                    session.editingImages.append(filePath)
                                } else {
                                    session.inputImages.append(filePath)
                                    print("Image saved to \(filePath)")
                                }
                            }
                        }
                    }
                }
                selectedItems = [] // Reset selection
            }
        }
//        .simultaneousGesture(LongPressGesture().onEnded { _ in
//            session.resetContext()
//        })

//        .padding(20) // Increase tappable area
//        .padding(-20) // Cancel out visual expansion
//        .background(Color.clear)
    }

    private var verticalPadding: CGFloat {
        return 7
    }

    private var imageSize: CGFloat {
        37
    }
}
#endif
