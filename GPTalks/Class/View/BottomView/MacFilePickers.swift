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
            HStack {
                Image(systemName: "photo")
                    .resizable()
                    .inputImageStyle(padding: 7, imageSize: 25)
                Text("Image")
            }
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
            if ![Model.gpt4t, Model.gpt4o].contains(session.configuration.model) {
                session.configuration.useVision = true
            }
        })
    }
}

struct AudioPickerView: View {
    var onAudioSelect: ((URL) -> Void)? // Closure to handle audio selection.
    
    @State private var importingAudio = false
    
    var body: some View {
        Button {
            importingAudio = true
        } label: {
            HStack {
                Image(systemName: "headphones")
                    .resizable()
                    .inputImageStyle(padding: 6, imageSize: 25)
                Text("Audio")
            }
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
                session.configuration.useTranscribe = true
            }
        })
    }
}

#endif

// consolodate the two
struct PDFPickerView: View {
    var onPDFAppend: ((URL) -> Void)?
    var imageSize: CGFloat
    var padding: CGFloat
    
    @State private var importingPDF = false
    
    var body: some View {
        Button {
            importingPDF = true
        } label: {
            HStack {
                Image(systemName: "newspaper")
//                    .resizable()
//                    .inputImageStyle(padding: padding, imageSize: imageSize)
                Text("PDF")
            }
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
    var padding: CGFloat
    
    private var currentPDFPath: Binding<String> {
        session.isEditing ? $session.editingPDFPath : $session.inputPDFPath
    }
    
    var body: some View {
        PDFPickerView(onPDFAppend: { selectedURL in
            withAnimation {
                currentPDFPath.wrappedValue = selectedURL.absoluteString
                showMore.wrappedValue = false
                session.configuration.useExtractPdf = true
            }
        }, imageSize: imageSize, padding: padding)
    }
}

#if os(macOS)
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func audioFileImporter(isPresented: Binding<Bool>, onFileSelected: @escaping (URL) -> Void) -> some View {
        self.fileImporter(
            isPresented: isPresented,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    onFileSelected(url)
                }
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
    }

    func pdfFileImporter(isPresented: Binding<Bool>, onFileSelected: @escaping (URL) -> Void) -> some View {
        self.fileImporter(
            isPresented: isPresented,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    onFileSelected(url)
                }
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
    }

    func imageFileImporter(isPresented: Binding<Bool>, onImageAppend: ((PlatformImage) -> Void)?) -> some View {
        self.fileImporter(
            isPresented: isPresented,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    if let image = NSImage(contentsOf: url) {
                        onImageAppend?(image)
                    }
                }
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
    }
}

extension View {
    func generalizedFileImporter(isPresented: Binding<Bool>, onFilesSelected: @escaping ([URL]) -> Void) -> some View {
        self.fileImporter(
            isPresented: isPresented,
            allowedContentTypes: [.audio, .pdf, .image],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                onFilesSelected(urls)
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
    }
}

#endif

