//
//  BottomInputView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/23.
//

import SwiftUI

struct BottomInputView: View {
    @ObservedObject var session: DialogueSession
    @State var isShowClearMessagesAlert = false
    @FocusState var isTextFieldFocused: Bool

    var send: (String) -> Void
    var stop: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            deleteButton

            inputBox

            if session.isReplying() {
                stopButton
            } else {
                sendButton
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 13)
        .alert(
            "Warning",
            isPresented: $isShowClearMessagesAlert
        ) {
            Button(role: .destructive) {
                session.clearMessages()
            } label: {
                Text("Confirm")
            }
        } message: {
            Text("Remove all messages?")
        }
    }

    @ViewBuilder
    private var deleteButton: some View {
        Button {
            isShowClearMessagesAlert.toggle()
        } label: {
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize - 1, height: imageSize - 1)
        }
        .buttonStyle(.borderless)
        .foregroundColor(.secondary)
    }

    @ViewBuilder
    private var sendButton: some View {
        Button {
            send(session.input)
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
        }
        .foregroundColor(session.input.isEmpty ? .tertiaryLabel : session.configuration.service.accentColor)
        .buttonStyle(.borderless)
        .disabled(session.input.isEmpty || session.isReplying())
    }

    @ViewBuilder
    private var stopButton: some View {
        Button {
            stop()
        } label: {
            Image(systemName: "stop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
                .foregroundColor(.systemRed)
        }
        .buttonStyle(.borderless)
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
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .stroke(.tertiary, lineWidth: 0.6)
                .opacity(0.8)
        )
    }

    @ViewBuilder
    private var textField: some View {
        TextField("Send a message", text: $session.input, axis: .vertical)
            .focused($isTextFieldFocused)
            .multilineTextAlignment(.leading)
            .lineLimit(1 ... 15)
            .padding(6)
            .padding(.horizontal, 4)
            .frame(minHeight: imageSize)
    }

    @ViewBuilder
    private var textEditor: some View {
        if session.input.isEmpty {
            Text("Send a message")
                .font(.body)
                .padding(7)
                .padding(.leading, 4)
                .foregroundColor(.placeholderText)
        }
        TextEditor(text: $session.input)
            .focused($isTextFieldFocused)
            .font(.body)
            .frame(maxHeight: 400)
            .fixedSize(horizontal: false, vertical: true)
            .padding(7)
            .scrollContentBackground(.hidden)
            .onKeyboardShortcut(.return, modifiers: .command) {
                if !session.input.isEmpty || session.isReplying() {
                    send(session.input)
                }
            }
    }

    private var imageSize: CGFloat {
        #if os(macOS)
            20
        #else
            22
        #endif
    }
}
