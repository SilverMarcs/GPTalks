//
//  CustomImportedImageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024.
//

import SwiftUI

struct CustomImageView: View {
    var image: PlatformImage // or NSImage for macOS
    
    var body: some View {
        Group {
#if os(macOS)
            Image(nsImage: image)
                .resizable()
#else
            Image(uiImage: image)
                .resizable()
#endif
        }
        .scaledToFill()
        .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
        .aspectRatio(contentMode: .fill)
        .cornerRadius(6)
    }
}

//struct ImportedImages: View {
//    var session: DialogueSession
//
//    var body: some View {
//        ScrollView(.horizontal) {
//            HStack {
//                ForEach(Array(session.inputImages.enumerated()), id: \.element) { index, inputImage in
//                    ZStack(alignment: .topTrailing) {
//                        CustomImageView(image: inputImage)
//                            .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
//                            .aspectRatio(contentMode: .fill)
//                            .cornerRadius(6)
//                        
//                        CustomCrossButton {
//                            session.inputImages.remove(at: index)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct ImportedEditingImages: View {
//    var session: DialogueSession
//
//    var body: some View {
//        ScrollView(.horizontal) {
//            HStack {
//                ForEach(Array(session.editingImages.enumerated()), id: \.element) { index, inputImage in
//                    ZStack(alignment: .topTrailing) {
//                        CustomImageView(image: inputImage)
//                            .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
//                            .aspectRatio(contentMode: .fill)
//                            .cornerRadius(6)
//                        
//                        CustomCrossButton {
//                            session.editingImages.remove(at: index)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}

import SwiftUI

// Assuming DialogueSession and CustomImageView are defined elsewhere
struct ImageScrollView: View {
    var images: [PlatformImage] // Adjust the type if necessary
    var removeAction: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(images.enumerated()), id: \.element) { index, image in
                    ZStack(alignment: .topTrailing) {
                        CustomImageView(image: image)
                            .frame(maxWidth: 100, maxHeight: 100)
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(6)

                        CustomCrossButton {
                            removeAction(index)
                        }
                    }
                }
            }
        }
    }
}

// Example usage within ImportedImages
struct ImportedImages: View {
    var session: DialogueSession

    var body: some View {
        ImageScrollView(images: session.inputImages, removeAction: { index in
            session.inputImages.remove(at: index)
        })
    }
}

// Example usage within ImportedEditingImages
struct ImportedEditingImages: View {
    var session: DialogueSession

    var body: some View {
        ImageScrollView(images: session.editingImages, removeAction: { index in
            session.editingImages.remove(at: index)
        })
    }
}

struct ImportedImagesView: View {
    var images: Binding<[PlatformImage]>
    var removeImageAtIndex: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(images.wrappedValue.enumerated()), id: \.element) { index, inputImage in
                    ZStack(alignment: .topTrailing) {
                        CustomImageView(image: inputImage)
                            .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(6)

                        CustomCrossButton {
                            removeImageAtIndex(index)
                        }
                    }
                }
            }
        }
    }
}


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
    }
}
