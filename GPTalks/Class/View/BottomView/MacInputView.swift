//
//  MacInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024.
//

import SwiftUI
import PhotosUI

struct MacInputView: View {
    @Bindable var session: DialogueSession
    
    @State private var importingImage = false
    @State private var importingAudio = false
    @State private var showMore = false
    
    @State var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !session.inputImages.isEmpty {
                ImportedImages(session: session)
            }
            
            if isAudioFile(urlString: session.inputAudioPath) {
                AudioPlayerView(audioURL: URL(string: session.inputAudioPath)!)
            }
            
            HStack(spacing: 12) {
                MoreOptions
                
                if showMore {
                    ImagePickerView(shouldAllowAdding: session.inputImages.count < 5) { newImage in
                        session.inputImages.append(newImage)
                        showMore = false
                    }
                    AudioPickerView(shouldAllowSelection: !session.shouldSwitchToVision) { selectedURL in
//                        session.input = selectedURL.absoluteString
                        session.inputAudioPath = selectedURL.absoluteString
                        showMore = false
                    }
                }

                MacTextEditor(input: $session.input)
                
                if session.isReplying {
                    StopButton {
                        session.stopStreaming()
                    }
                } else {
                    MacSendButton(isInputEmpty: session.input.isEmpty, isReplying: session.isReplying) {
                        Task { @MainActor in
                            selectedItems = []
                            await session.send()
                        }
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
        .padding(.top, verticalPadding)
        .padding(.bottom, verticalPadding + 2)
    }
    
    var MoreOptions: some View {
        Button {
            showMore.toggle()
        } label: {
            Image(systemName: "plus")
                .resizable()
                .inputImageStyle(padding: 6, imageSize: imageSize + 2)
                .rotationEffect(.degrees(showMore ? 45 : 0))
                .animation(.default, value: showMore)
        }
    }
   
    private var verticalPadding: CGFloat {
        13
    }
    
    private var imageSize: CGFloat {
        21
    }
}

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
                .inputImageStyle(padding: 7, imageSize: 26)
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
                .inputImageStyle(padding: 6, imageSize: 23)
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
