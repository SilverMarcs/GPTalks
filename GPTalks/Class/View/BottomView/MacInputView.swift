//
//  MacInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024..
//

import SwiftUI
import PhotosUI
import PDFKit
import QuickLook

#if os(macOS)
struct MacInputView: View {
    @Environment(DialogueViewModel.self) private var viewModel
    
    @Bindable var session: DialogueSession
    
    @State private var importingImage = false
    @State private var importingAudio = false
    @State private var showMore = false
    
    @State var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            importedImages
            
            importedPDF
            
            importedAudio
            
            HStack(alignment: .bottom, spacing: 12) {
                Group {
                    if session.isEditing {
                        StopEditing() {
                            session.resetIsEditing()
                        }
                        
                    }
                    MoreOptions
                        
                    if showMore {
                        ImagePickerView(shouldAllowAdding: shouldAllowAddingImages(), onImageAppend: { newImage in
                            if session.isEditing {
                                session.editingImages.append(newImage)
                            } else {
                                session.inputImages.append(newImage)
                            }
                            showMore = false
                        })
                        .offset(y: 2)
                        .padding(.top, -2)
                        .disabled(!session.inputAudioPath.isEmpty || (session.isEditing && !session.editingAudioPath.isEmpty))
                        
                        PDFPickerView(shouldAllowAdding: !session.shouldSwitchToVision, onPDFAppend: { selectedURL in
                            withAnimation {
                                if session.isEditing {
                                    session.editingPDFPath = selectedURL.absoluteString
                                    print("Editing PDF: \(selectedURL.absoluteString)")
                                } else {
                                    session.inputPDFPath = selectedURL.absoluteString
                                    print(selectedURL.absoluteString)
                                }
                            }
                            showMore = false
                        })
                        .offset(y: 1)
                        
                        AudioPickerView(shouldAllowSelection: !session.shouldSwitchToVision, onAudioSelect: { selectedURL in
                            withAnimation {
                                if session.isEditing {
                                    session.editingAudioPath = selectedURL.absoluteString
                                } else {
                                    session.inputAudioPath = selectedURL.absoluteString
                                }
                            }
                            showMore = false
                        })
                    }
                    
                }
                .offset(y: -1)
                
                if session.isEditing {
                    MacTextEditor(input: $session.editingMessage)
                } else {
                    MacTextEditor(input: $session.input)
                }
                
                Group {
                    if session.isReplying {
                        StopButton (size: imageSize + 4 ) { session.stopStreaming() }
                    } else {
                        SendButton(size: imageSize + 4) {
                            if session.isEditing {
                                Task { @MainActor in
                                    viewModel.moveUpChat(session: session)
                                    await session.edit()
                                }
                                
                            } else {
                                Task { @MainActor in
                                    selectedItems = []
                                    viewModel.moveUpChat(session: session)
                                    await session.send()
                                }
                            }
                        }
                        .disabled((!session.isEditing && session.input.isEmpty) || (session.isEditing && session.editingMessage.isEmpty))
                    }
                }
                .offset(y: -1)
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
        .padding(.top, verticalPadding - 2)
        .padding(.bottom, verticalPadding + 2)
    }
    
    @ViewBuilder
    var importedImages: some View {
        if !session.inputImages.isEmpty || (session.isEditing && !session.editingImages.isEmpty) {
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
    }
    
    @ViewBuilder
    var importedPDF: some View {
        if !session.inputPDFPath.isEmpty || (session.isEditing && !session.editingPDFPath.isEmpty) {
            if session.isEditing {
                PDFViewer(pdfURL: URL(string: session.editingPDFPath)!, removePDFAction: {
                    withAnimation {
                        session.editingPDFPath = ""
                    }
                })
            } else {
                PDFViewer(pdfURL: URL(string: session.inputPDFPath)!, removePDFAction: {
                    withAnimation {
                        session.inputPDFPath = ""
                    }
                })
            }
        }
    }
    
    @ViewBuilder
    var importedAudio: some View {
        if !session.inputAudioPath.isEmpty || (session.isEditing && !session.editingAudioPath.isEmpty) {
            if session.isEditing {
                UniversalAudioPlayer(audioURL: URL(string: session.editingAudioPath)!) {
                    withAnimation {
                        session.editingAudioPath = ""
                    }
                }
            } else {
                UniversalAudioPlayer(audioURL: URL(string: session.inputAudioPath)!) {
                    withAnimation {
                        session.inputAudioPath = ""
                    }
                }
            }
        }
    }
    
    var MoreOptions: some View {
        Button {
            showMore.toggle()
        } label: {
            Image(systemName: "plus")
                .resizable()
                .inputImageStyle(padding: 6, imageSize: imageSize + 3)
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
    
    func shouldAllowAddingImages() -> Bool {
        if session.isEditing {
            return session.editingImages.count < 5
        } else {
            return session.inputImages.count < 5
        }
    }
}

struct StopEditing: View {
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .padding(6)
                .fontWeight(.bold)
                .foregroundStyle(.bar)
                .background(.red)
                .clipShape(Circle())
                .frame(width: 24, height: 24)
                .rotationEffect(.degrees(45))
        }
        .keyboardShortcut(.cancelAction)
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
                .inputImageStyle(padding: 7, imageSize: 28)
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
                .inputImageStyle(padding: 7, imageSize: 26)
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
                .inputImageStyle(padding: 6, imageSize: 24)
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

struct UniversalAudioPlayer: View {
    var audioURL: URL
    var removeAudioAction: () -> Void
    
    @State var qlItem: URL?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
//            if let url = URL(string: audioURLString) {
////                AudioPlayerView(audioURL: url)
//                Text("Audio Player")
//                    .onTapGesture {
//                        audioURL = URL(string: audioURLString)
//                    }
//                    .quickLookPreview($audioURL)
//            } else {
//                // Handle invalid URL or show placeholder
//                Text("Invalid URL")
//            }
            
            HStack {
                Text(audioURL.lastPathComponent)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                
                Image(systemName: "waveform")
                    .imageScale(.medium)
            }
            .bubbleStyle(isMyMessage: false)
            .onTapGesture {
                qlItem = audioURL
            }
            .quickLookPreview($qlItem)
            
            CustomCrossButton(action: removeAudioAction)
                .padding(-10)
        }
    }
}

struct PDFViewer: View {
    var pdfURL: URL
    var removePDFAction: () -> Void
    
    @State var qlItem: URL?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                qlItem = pdfURL
            } label: {
                HStack {
                    Text(pdfURL.lastPathComponent)
                        .font(.callout)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "doc.richtext.fill")
                        .imageScale(.medium)
                }
                .bubbleStyle(isMyMessage: false)
            }
            .buttonStyle(.plain)

            // TODO: show this based on a a prameter
            CustomCrossButton(action: removePDFAction)
                .padding(-10)
        }
        .quickLookPreview($qlItem)
    }
}

#endif
