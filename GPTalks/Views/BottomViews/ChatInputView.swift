//
//  ChatInputView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import TipKit

struct ChatInputView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var config = AppConfig.shared
    
    @Bindable var chat: Chat

    @State private var isExpanded = false
    @State private var showExpandButton = false
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(spacing: 5) {
                if chat.inputManager.state == .editing {
                    cancelEditing
                }

                ChatInputMenu(chat: chat)
            }
            
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    #if os(macOS)
                    TipView(PlusButtonTip())
                        .frame(height: 30)
                        .padding(.bottom, 20)
                    #endif
                    
                    if !chat.inputManager.dataFiles.isEmpty {
                        DataFilesView(dataFiles: chat.inputManager.dataFiles, edge: .leading) { file in
                            withAnimation {
                                chat.inputManager.dataFiles.removeAll(where: { $0 == file })
                            }
                        }
                        .padding(.bottom, 5)
                    }
                    
                    InputEditor(chat: chat)
                        .onChange(of: chat.inputManager.prompt) {
                            showExpandButton = chat.inputManager.prompt.contains("\n")
                        }
                }
                .padding(4)
                
                VStack {
                    if showExpandButton || isExpanded {
                        expandInput
                            .padding(3)
                        
                        Spacer()
                    }
                    
                    ActionButton(isStop: chat.isReplying) {
                        chat.isReplying ? chat.stopStreaming() : sendInput()
                    }
                }
            }
            .padding(2)
            .roundedRectangleOverlay()
        }
        .modifier(CommonInputStyling())
    }
    
    var truncateLimit: Int {
        #if os(macOS)
        130
        #else
        35
        #endif
    }
        
    var expandInput: some View {
        Button {
            isExpanded.toggle()
        } label: {
            Image(systemName: isExpanded ? "arrow.up.right.and.arrow.down.left" : "arrow.down.left.and.arrow.up.right")
                .padding(3)
        }
        .transition(.symbolEffect(.appear))
        .buttonStyle(.plain)
        .sheet(isPresented: $isExpanded) {
            ExpandedInputEditor(prompt: $chat.inputManager.prompt)
        }
    }
    
    var cancelEditing: some View {
        Button {
            withAnimation {
                chat.inputManager.reset()
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                #if os(macOS)
                .font(.system(size: 25, weight: .semibold))
                #else
                .font(.system(size: 31, weight: .semibold))
                #endif
                .foregroundStyle(.red)
        }
        .transition(.symbolEffect(.appear))
        .buttonStyle(.plain)
        .keyboardShortcut(.cancelAction)
    }
    
    private func sendInput() {
        #if os(iOS)
//        isFocused = nil // doesn't work
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
        Task { @MainActor in
            await chat.sendInput()
        }
    }
}

import SwiftData
#Preview {
    ChatDetail(chat: .mockChat)
        .environment(ChatVM())
}
