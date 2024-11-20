//
//  InputEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI

struct InputEditor: View {
    @Environment(ChatVM.self) private var chatVM
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat
    @FocusState var isFocused: FocusedField?
    
    var body: some View {
        #if os(macOS)
        Group {
            if config.enterToSend {
                TextField(placeHolder, text: $chat.inputManager.prompt, axis: .vertical)
                    .lineLimit(25, reservesSpace: false)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        if NSApp.currentEvent?.modifierFlags.contains(.shift) == true {
                            chat.inputManager.prompt += "\n"
                        } else {
                            Task { @MainActor in
                                await chat.sendInput()
                            }
                        }
                    }
            } else {
                ZStack(alignment: .leading) {
                    if chat.inputManager.prompt.isEmpty {
                        Text(placeHolder)
                            .padding(.leading, 3)
                            .foregroundStyle(.placeholder)
                    }
                    
                    TextEditor(text: $chat.inputManager.prompt)
                        .frame(maxHeight: 400)
                        .fixedSize(horizontal: false, vertical: true)
                        .scrollContentBackground(.hidden)
                }
                .font(.body)
            }
        }
        .focused($isFocused, equals: .textEditor)
        .task(id: chatVM.selections) {
            guard chatVM.selections.count == 1 else { return }
            isFocused = .textEditor
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button {
                    isFocused = .textEditor
                } label: {
                    Image(systemName: "pencil")
                }
                .keyboardShortcut("l")
            }
        }
        #else
        TextField(placeHolder, text: $chat.inputManager.prompt, axis: .vertical)
            .focused($isFocused, equals: .textEditor)
            .lineLimit(10, reservesSpace: false)
            .onSubmit {
                if config.enterToSend {
//                    isFocused = nil // doesn't work
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    Task { @MainActor in
                        await chat.sendInput()
                    }
                } else {
                    chat.inputManager.prompt += "\n"
                }
            }
        #endif
    }
    
    var placeHolder: String {
        "Send a prompt • \(chat.config.provider.name)"
    }
}
