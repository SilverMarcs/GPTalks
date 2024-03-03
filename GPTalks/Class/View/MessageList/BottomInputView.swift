//
//  BottomInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI
#if os(iOS)
import VisualEffectView
#endif
import PhotosUI

struct BottomInputView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Bindable var session: DialogueSession
    
    @FocusState var focused: Bool
    
    @State private var importing = false
    @State var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !session.inputImages.isEmpty {
                importedImages
            }
            
            HStack(spacing: 12) {
                #if os(macOS)
                imagePicker
                #else
                iosMore
                #endif
                
                inputBox
                    .onTapGesture {
                        focused = true
                    }
                
                #if os(macOS)
                if session.isReplying() {
                    stopButton
                } else {
                    sendButton
                }
                #endif
            }
        }
        .animation(.default, value: session.inputImages)
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.top, verticalPadding)
        .padding(.bottom, verticalPadding + 2)
    }
    
    private var verticalPadding: CGFloat {
        #if os(iOS)
        return 7
        #else
        return 13
        #endif
    }
    
    // TODO: use ImageView here later
    var importedImages: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(session.inputImages.enumerated()), id: \.element) { index, inputImage in
                    ZStack(alignment: .topTrailing) {
#if os(macOS)
                        Image(nsImage: inputImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(6)
                        
#else
                        
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(6)
                        
#endif
                        Button {
                            session.inputImages.remove(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.background)
                                .background(.primary, in: Circle())
                        }
                        .padding(7)
                    }
                }
            }
        }
    }
    
    #if !os(macOS)
    
    var iosMore: some View {
        Menu {
            Button {
                session.resetContext()
            } label: {
                Label("Reset Context", systemImage: "eraser")
            }
            
            Button {
                Task {
                    await session.regenerateLastMessage()
                }
            } label: {
                Label("Regenerate", systemImage: "arrow.2.circlepath")
            }
            
            Button {
                importing = true
            } label: {
                Label("Add Image", systemImage: "photo")
            }
            
        } label: {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .padding(10)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .background(.gray.opacity(0.2))
                .clipShape(Circle())
                .frame(width: imageSize + 3, height: imageSize + 3)
        }
        .photosPicker(
            isPresented: $importing,
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

    #endif
    
    var imagePicker: some View {
        Button {
            importing = true
        } label: {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .padding(6)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .background(.gray.opacity(0.2))
                .clipShape(Circle())
                .frame(width: imageSize + 1, height: imageSize + 1)
        }
        .keyboardShortcut("i", modifiers: .command)
        .fileImporter(
            isPresented: $importing,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let files): // 'files' is now an array of URLs
                for file in files { // Iterate over each file
                    #if os(macOS)
                    let image = NSImage(contentsOf: file)
                    #else
                    let image = UIImage(contentsOfFile: file.path)
                    #endif
                    
                    if let image = image {
                        session.inputImages.append(image)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        .disabled(session.inputImages.count >= 5)
    }
    
    @ViewBuilder
    private var resetContextButton: some View {
        Button {
            session.resetContext()
        } label: {
            Image(systemName: "eraser")
                .resizable()
                .scaledToFit()
            #if os(macOS)
                .frame(width: imageSize, height: imageSize)
            #else
                .padding(8)
                .background(.gray.opacity(0.2))
                .clipShape(Circle())
                .frame(width: imageSize + 3, height: imageSize + 3)
            #endif
        }
        .foregroundColor(session.isReplying() ? placeHolderTextColor : .secondary)
        .disabled(session.conversations.isEmpty || session.isReplying())
        .contentShape(Rectangle())
    }
    
    private var regenButton: some View {
        Button {
            Task { @MainActor in
                await session.regenerateLastMessage()
            }
        } label: {
            Image(systemName: "arrow.2.circlepath")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
        }
        .foregroundColor(session.isReplying() ? placeHolderTextColor : .secondary)
        .buttonStyle(.plain)
        .disabled(session.conversations.isEmpty || session.isReplying())
    }

    @ViewBuilder
    private var sendButton: some View {
        let empty = session.input.isEmpty
        
        Button {
            #if os(iOS)
            focused = false
            #endif
            
            Task { @MainActor in
                selectedItems = []
                await session.send()
            }
        } label: {
            Image(systemName: empty ? "arrow.up.circle" : "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
                .disabled(empty)
                .foregroundColor(empty ? .secondary : .accentColor)
            #if os(macOS)
                .frame(width: imageSize + 1, height: imageSize + 1)
            #else
                .background(.white)
                .clipShape(Circle())
                .frame(width: imageSize - 3, height: imageSize - 3)
            #endif
        }
        .keyboardShortcut(.return, modifiers: .command)
        .foregroundColor(session.isReplying() || empty ? placeHolderTextColor : .secondary)
        .disabled(empty || session.isReplying())
        .fontWeight(.semibold)
        .animation(.interactiveSpring, value: empty)
//        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var stopButton: some View {
        Button {
            session.stopStreaming()
        } label: {
            Image(systemName: "stop.circle.fill")
                .resizable()
                .scaledToFit()
            #if os(macOS)
                .frame(width: imageSize, height: imageSize)
            #else
                .frame(width: imageSize - 3, height: imageSize - 3)
            #endif
                .foregroundColor(.red)
        }
        .keyboardShortcut("d", modifiers: .command)
    }

    @ViewBuilder
    private var inputBox: some View {
        ZStack(alignment: .leading) {
            #if os(macOS)
            textEditor
            #else
            textField
            #endif
        }
        .roundedRectangleOverlay()
    }

    @ViewBuilder
    private var textField: some View {
        ZStack(alignment: .bottomTrailing) {
            TextField("Send a message", text: $session.input, axis: .vertical)
                .focused($focused)
                .multilineTextAlignment(.leading)
                .lineLimit(1 ... 15)
                .padding(6)
                .padding(.horizontal, 5)
                .padding(.trailing, 25) // for avoiding send button
                .frame(minHeight: imageSize + 5)
            #if os(iOS)
                .background(
                    VisualEffect(colorTint: colorScheme == .dark ? .black : .white, colorTintAlpha: 0.3, blurRadius: 18, scale: 1)
                        .cornerRadius(18)
                )
            #endif
            
            Group {
                if session.input.isEmpty && !session.isReplying() {
                    Button {} label: {
                        Image(systemName: "mic.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize - 13, height: imageSize - 13)
                            .foregroundStyle(.secondary)
                            .opacity(0.5)
                    }
                    .offset(x: -10, y: -9)
                } else {
                    if session.isReplying() {
                        stopButton
                            .offset(x: -4, y: -4)
                        
                    } else {
                        sendButton
                            .offset(x: -4, y: -4)
                    }
                }
            }
            .padding(20) // Increase tappable area
            .padding(-20) // Cancel out visual expansion
            .background(Color.clear)
        }
    }

    @ViewBuilder
    private var textEditor: some View {
        if session.input.isEmpty {
            Text("Send a message")
                .font(.body)
                .padding(5)
                .padding(.leading, 6)
                .foregroundColor(placeHolderTextColor)
        }
        TextEditor(text: $session.input)
            .focused($focused)
            .font(.body)
            .frame(maxHeight: 400)
            .fixedSize(horizontal: false, vertical: true)
            .padding(5)
            .scrollContentBackground(.hidden)
        Button("hidden") {
            focused = true
        }
        .keyboardShortcut("l", modifiers: .command)
        .hidden()
    }

    private var imageSize: CGFloat {
        #if os(macOS)
        21
        #else
        31
        #endif
    }
    
    private var placeHolderTextColor: Color {
        #if os(macOS)
        Color(.placeholderTextColor)
        #else
        Color(.placeholderText)
        #endif
    }
}
