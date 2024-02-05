//
//  BottomInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct BottomInputView: View {
    @Bindable var session: DialogueSession
    
    @FocusState var focused: Bool
    
    @State private var importing = false
    @State private var image: Image?
    
    var body: some View {
        VStack(alignment: .leading) {
            importedImage
            
            HStack(spacing: 12) {
//                imagePicker
                resetContextButton
                
                inputBox
                
                if session.isReplying() {
                    stopButton
                } else {
                    sendButton
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.vertical, verticalPadding)
    }
    
    private var verticalPadding: CGFloat {
        #if os(iOS)
        return 6
        #else
        return 13
        #endif
    }
    
    var importedImage: some View {
        ZStack(alignment: .topTrailing) {
            image?
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            if image != nil {
                Button {
                    image = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.background)
                        .background(.primary, in: Circle())
                }
            }
        }
    }
    
    var imagePicker: some View {
        Button {
            importing = true
        } label: {
            Image(systemName: "photo")
                .frame(width: imageSize, height: imageSize)
        }
        .fileImporter(
            isPresented: $importing,
            allowedContentTypes: [.image]
        ) { result in
            switch result {
            case .success(let file):
                print(file.absoluteString)
                #if os(macOS)
                if let nsImage = NSImage(contentsOf: file) {
                    image = Image(nsImage: nsImage)
                }
                #else
                if let uiImage = UIImage(contentsOfFile: file.path) {
                    image = Image(uiImage: uiImage)
                }
                #endif
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
                .frame(width: imageSize - 1, height: imageSize - 1)
            #endif
        }
        .foregroundColor(session.isReplying() ? placeHolderTextColor : .secondary)
        .disabled(session.conversations.isEmpty || session.isReplying())
        .rotationEffect(.degrees(135))
        .padding(.horizontal, -2)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var sendButton: some View {
        let empty = session.input.isEmpty
        
        Button {
            #if os(iOS)
            focused = false
            #endif
            
           Task { @MainActor in
               await session.send()
           }
        } label: {
            Image(systemName: empty ? "arrow.up.circle" : "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
                .disabled(empty)
                .foregroundColor(empty ? .secondary : .accentColor)
                .frame(width: imageSize, height: imageSize)
        }
        .keyboardShortcut(.return, modifiers: .command)
        .foregroundColor(session.isReplying() || empty ? placeHolderTextColor : .secondary)
        .disabled(session.input.isEmpty || session.isReplying())
        .fontWeight(session.input.isEmpty ? .regular : .semibold)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var stopButton: some View {
        Button {
            session.stopStreaming()
        } label: {
            Image(systemName: "stop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
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
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.tertiary, lineWidth: 0.6)
                .opacity(0.8)
        )
    }

    @ViewBuilder
    private var textField: some View {
        TextField("Send a message", text: $session.input, axis: .vertical)
            .focused($focused)
            .multilineTextAlignment(.leading)
            .lineLimit(1 ... 15)
            .padding(6)
            .padding(.horizontal, 4)
            .frame(minHeight: imageSize + 6)
    }

    @ViewBuilder
    private var textEditor: some View {
        if session.input.isEmpty {
            Text("Send a message")
                .font(.body)
                .padding(6)
                .padding(.leading, 4)
                .foregroundColor(placeHolderTextColor)
        }
        TextEditor(text: $session.input)
            .focused($focused)
            .font(.body)
            .frame(maxHeight: 400)
            .fixedSize(horizontal: false, vertical: true)
            .padding(6)
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
            27
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
