//
//  ComposerInputView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/17.
//


import SwiftUI

struct ComposerInputView: View {
    
    @ObservedObject var session: DialogueSession
    @FocusState var isTextFieldFocused: Bool
    
    var send: (String) -> Void
    
    private var size: CGFloat {
#if os(macOS)
        20
#else
        26
#endif
    }
    
    var radius: CGFloat {
#if os(macOS)
        16
#else
        17
#endif
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            #if os(macOS)
            textEditor
            #else
            textField
            #endif
            sendButton
        }
        .padding(4)
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(.tertiary, lineWidth: 0.6)
                .opacity(0.8)
        )
        .padding(.trailing)
        .padding(.leading, 4)
    }
    
    @ViewBuilder
    private var textEditor: some View {
        ZStack(alignment: .leading) {
            if session.input.isEmpty {
                Text("Send a message")
                    .font(.system(size: 13))
                    .padding(.leading, 6)
                    .padding(.trailing, size + 6)
                    .foregroundColor(.placeholderText)
            }
            TextEditor(text: $session.input)
                .focused($isTextFieldFocused)
                .font(.system(size: 13, weight: .regular, design: .default))
                .frame(minHeight: size, maxHeight: 410)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 3)
                .padding(.trailing, size + 6)
                .padding(.top, 4)
                .scrollContentBackground(.hidden)
                .onKeyboardShortcut(.return, modifiers: .command) {
                    send(session.input)
                }
        }

    }
    
    @ViewBuilder
    private var textField: some View {
        TextField("Send a message", text: $session.input, axis: .vertical)
            .focused($isTextFieldFocused)
            .multilineTextAlignment(.leading)
            .lineLimit(1...20)
            .padding(.leading, 12)
            .padding(.trailing, size + 6)
            .frame(minHeight: size)
#if os(macOS)
            .textFieldStyle(.plain)
#endif
    }

    @ViewBuilder
    private var sendButton: some View {
        if !session.input.isEmpty {
            Button {
                send(session.input)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundColor(.accentColor)
                    .font(.body.weight(.semibold))
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.defaultAction)
        } else {
#if os(iOS)
            Button {
                
            } label: {
                Image(systemName: "mic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.secondary)
                    .opacity(0.7)
            }
            .offset(x:-4, y: -4)
#endif
        }
    }
    
}
