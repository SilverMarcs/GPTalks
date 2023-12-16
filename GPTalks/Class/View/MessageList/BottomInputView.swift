//
//  BottomInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI

struct BottomInputView: View {
    @ObservedObject var session: DialogueSession
    @State var isShowClearMessagesAlert = false

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 12) {
            regenButton

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
    private var regenButton: some View {
        Button {
            Task { @MainActor in
                await session.regenerateLastMessage()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
        }
        .foregroundColor(session.isReplying() ? placeHolderTextColor : .secondary)
        .buttonStyle(.plain)
        .disabled(session.conversations.isEmpty || session.isReplying())
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
        let empty = session.input.isEmpty
        
        Button {
           Task { @MainActor in
               await session.send()
           }
        } label: {
            Image(systemName: empty ? "arrow.up.circle" : "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
                .disabled(empty)
                .foregroundColor(empty ? .secondary : session.configuration.provider.accentColor)
                .frame(width: imageSize, height: imageSize)
        }
        .keyboardShortcut(.return, modifiers: .command)
        .foregroundColor(session.isReplying() || empty ? placeHolderTextColor : .secondary)
        .buttonStyle(.plain)
        .disabled(session.input.isEmpty || session.isReplying())
    }

    @ViewBuilder
    private var stopButton: some View {
        Button {
            session.stopStreaming()
        } label: {
            Image(systemName: "stop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize + 1, height: imageSize + 1)
                .foregroundColor(.red)
        }
        .buttonStyle(.plain)
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
                .foregroundColor(placeHolderTextColor)
        }
        TextEditor(text: $session.input)
            .font(.body)
            .frame(maxHeight: 400)
            .fixedSize(horizontal: false, vertical: true)
            .padding(7)
            .scrollContentBackground(.hidden)
    }

    private var imageSize: CGFloat {
        #if os(macOS)
            18
        #else
            24
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
