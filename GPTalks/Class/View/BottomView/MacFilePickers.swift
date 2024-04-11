//
//  MacFilePickers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/04/2024.
//

import SwiftUI

#if os(macOS)
struct ImagePickerView: View {
    var onImageAppend: ((NSImage) -> Void)?
    
    @State private var importingImage = false
    
    var body: some View {
        Button {
            importingImage = true
        } label: {
            Image(systemName: "photo")
                .resizable()
                .inputImageStyle(padding: 7, imageSize: 25)
        }
        .fileImporter(
            isPresented: $importingImage,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let files):
                for file in files {
                    guard let image = NSImage(contentsOf: file) else { continue }
                    onImageAppend?(image)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct AudioPickerView: View {
    var onAudioSelect: ((URL) -> Void)? // Closure to handle audio selection.
    
    @State private var importingAudio = false
    
    var body: some View {
        Button {
            importingAudio = true
        } label: {
            Image(systemName: "waveform")
                .resizable()
                .inputImageStyle(padding: 6, imageSize: 25)
        }
        .fileImporter(
            isPresented: $importingAudio,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                let url = urls[0]
                onAudioSelect?(url)
                print("Selected file URL: \(url)")
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
    }
}

struct CustomImagePickerView: View {
    @Bindable var session: DialogueSession
    var showMore: Binding<Bool>
    
    private var currentImages: Binding<[PlatformImage]> {
        session.isEditing ? $session.editingImages : $session.inputImages
    }
    
    var body: some View {
        ImagePickerView(onImageAppend: { newImage in
            currentImages.wrappedValue.append(newImage)
            showMore.wrappedValue = false
        })
    }
}

struct CustomAudioPickerView: View {
    @Bindable var session: DialogueSession
    var showMore: Binding<Bool>
    
    private var currentAudioPath: Binding<String> {
        session.isEditing ? $session.editingAudioPath : $session.inputAudioPath
    }
    
    var body: some View {
        AudioPickerView(onAudioSelect: { selectedURL in
            withAnimation {
                currentAudioPath.wrappedValue = selectedURL.absoluteString
                showMore.wrappedValue = false
            }
        })
    }
}

#endif

// consolodate the two
struct PDFPickerView: View {
    var onPDFAppend: ((URL) -> Void)?
    var imageSize: CGFloat
    
    @State private var importingPDF = false
    
    var body: some View {
        Button {
            importingPDF = true
        } label: {
            Image(systemName: "doc.richtext")
                .resizable()
                .inputImageStyle(padding: 7, imageSize: imageSize)
        }
        .fileImporter(
            isPresented: $importingPDF,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                onPDFAppend?(urls[0])
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}


struct CustomPDFPickerView: View {
    @Bindable var session: DialogueSession
    var showMore: Binding<Bool>
    var imageSize: CGFloat
    
    private var currentPDFPath: Binding<String> {
        session.isEditing ? $session.editingPDFPath : $session.inputPDFPath
    }
    
    var body: some View {
        PDFPickerView(onPDFAppend: { selectedURL in
            withAnimation {
                currentPDFPath.wrappedValue = selectedURL.absoluteString
                showMore.wrappedValue = false
            }
        }, imageSize: imageSize)
    }
}



struct CombinedPDFPickerView: View {
    @Bindable var session: DialogueSession
    var showMore: Binding<Bool>
    var imageSize: CGFloat
    var padding: CGFloat
    
    @State private var importingPDF = false
    
    private var currentPDFPath: Binding<String> {
        session.isEditing ? $session.editingPDFPath : $session.inputPDFPath
    }
    
    var body: some View {
        Button {
            importingPDF = true
        } label: {
            Image(systemName: "doc.richtext")
                .resizable()
                .inputImageStyle(padding: padding, imageSize: imageSize)
        }
        .fileImporter(
            isPresented: $importingPDF,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                withAnimation {
                    currentPDFPath.wrappedValue = urls[0].absoluteString
                    showMore.wrappedValue = false
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
