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
#endif


#if os(macOS)
import SwiftUI
import UniformTypeIdentifiers


extension View {
    func imageFileImporter(isPresented: Binding<Bool>, onFilesSelected: @escaping ([URL]) -> Void) -> some View {
        self.fileImporter(
            isPresented: isPresented,
            allowedContentTypes: [.image],
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

