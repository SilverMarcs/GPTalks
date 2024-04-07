//
//  MacFilePickers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/04/2024.
//

import SwiftUI

struct ImagePickerView: View {
    var shouldAllowAdding: Bool
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
        .disabled(!shouldAllowAdding)
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

struct PDFPickerView: View {
    var shouldAllowAdding: Bool
    var onPDFAppend: ((URL) -> Void)?
    
    @State private var importingPDF = false
    
    var body: some View {
        Button {
            importingPDF = true
        } label: {
            Image(systemName: "doc.richtext")
                .resizable()
                .inputImageStyle(padding: 7, imageSize: 25)
        }
        .disabled(!shouldAllowAdding)
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

struct AudioPickerView: View {
    var shouldAllowSelection: Bool // Condition to enable or disable the picker.
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
        .disabled(!shouldAllowSelection)
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
    
    private func shouldAllowAddingImages() -> Bool {
        currentImages.wrappedValue.count < 5
    }
    
    
    var body: some View {
        ImagePickerView(shouldAllowAdding: shouldAllowAddingImages(), onImageAppend: { newImage in
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
        AudioPickerView(shouldAllowSelection: !session.shouldSwitchToVision, onAudioSelect: { selectedURL in
            withAnimation {
                currentAudioPath.wrappedValue = selectedURL.absoluteString
                showMore.wrappedValue = false
            }
        })
    }
}

struct CustomPDFPickerView: View {
    @Bindable var session: DialogueSession
    var showMore: Binding<Bool>
    
    private var currentPDFPath: Binding<String> {
        session.isEditing ? $session.editingPDFPath : $session.inputPDFPath
    }
    
    var body: some View {
        PDFPickerView(shouldAllowAdding: !session.shouldSwitchToVision, onPDFAppend: { selectedURL in
            withAnimation {
                currentPDFPath.wrappedValue = selectedURL.absoluteString
                showMore.wrappedValue = false
            }
        })
    }
}
