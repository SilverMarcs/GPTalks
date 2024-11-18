//
//  MessageMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct MessageMenu: View {
    @Environment(ChatVM.self) private var chatVM
    @Environment(\.isQuick) private var isQuick
    @Environment(\.providers) var providers
    
    var message: Message
    
    @Binding var isExpanded: Bool
    var toggleTextSelection: (() -> Void)? = nil
    
    @State var isCopied = false
    @State var isForking = false

    var body: some View {
        #if os(macOS)
            HStack {
                buttons
                    .buttonStyle(HoverScaleButtonStyle())
            }
            .transaction { $0.animation = nil }
            .frame(height: 20)
        #else
            buttons
        #endif
    }

    @ViewBuilder
    var buttons: some View {
        expandHeight
        
        Section {
            editMessage
            
            regenMessage
        }
    
        Section {
            copyText
            
            forkChat
            #if !os(macOS)
            selectText
            #endif
        }
        
        Section {
            resetContext
            
            deleteMessage
        }
    }
    
    @ViewBuilder
    var editMessage: some View {
        if !isQuick && message.role == .user {
            Button {
                message.chat?.inputManager.setupEditing(message: message)
            } label: {
                Label("Edit", systemImage: "pencil.and.outline")
            }
            .help("Edit")
        }
    }
    
    @ViewBuilder
    var expandHeight: some View {
        if message.role == .user {
            Button {
                isExpanded.toggle()
                AppConfig.shared.proxy?.scrollTo(message, anchor: .top)
            } label: {
                Label(isExpanded ? "Collapse" : "Expand", systemImage: isExpanded ? "arrow.up.right.and.arrow.down.left" : "arrow.down.left.and.arrow.up.right")
            }
            .contentTransition(.symbolEffect(.replace))
            .help("Expand")
        }
    }

    @ViewBuilder
    var forkChat: some View {
        if isForking {
            ProgressView()
                .controlSize(.small)
        } else {
            Button {
                isForking = true
                Task {
                    if let newChat = await message.chat?.copy(from: message, purpose: .chat) {
                        chatVM.fork(newChat: newChat)
                        isForking = false
                    }
                }
            } label: {
                Label("Fork Session", systemImage: "arrow.branch")
            }
            .help("Fork Session")
        }
    }

    var copyText: some View {
        Button {
            message.content.copyToPasteboard()
            
            isCopied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isCopied = false
            }
        } label: {
            Label(isCopied ? "Copied" : "Copy Text", systemImage: isCopied ? "checkmark" : "paperclip")
        }
        .contentTransition(.symbolEffect(.replace))
    }
    
    var selectText: some View {
        Button {
            toggleTextSelection?()
        } label: {
            Label("Select Text", systemImage: "text.cursor")
        }
        .help("Select Text")
    }

    var resetContext: some View {
        Button {
            message.chat?.resetContext(at: message)
        } label: {
            Label("Reset Context", systemImage: "eraser")
        }
        .help("Reset Context")
    }
    
    var deleteMessage: some View {
        Button(role: .destructive) {
            message.chat?.deleteMessage(message)
        } label: {
            #if os(macOS)
            Image(systemName: "trash")
                .resizable()
                .frame(width: 11, height: 13)
            #else
            Label("Delete", systemImage: "trash")
            #endif
        }
        .help("Delete")
    }

    var regenMessage: some View {
        #if os(macOS)
        Menu {
            ForEach(providers) { provider in
                Menu {
                    ForEach(provider.chatModels) { model in
                        Button(model.name) {
                            message.chat?.config.provider = provider
                            message.chat?.config.model = model
                            
                            regen()
                        }
                    }
                } label: {
                    Text(provider.name)
                }
            }
        } label: {
            Label("Regenerate", systemImage: "arrow.2.circlepath")
        } primaryAction: {
            regen()
        }
        .menuStyle(HoverScaleMenuStyle())
        #else
        Button {
            regen()
        } label: {
            Label("Regenerate", systemImage: "arrow.2.circlepath")
        }
        #endif
    }
    
    func regen() {
        Task {
            await message.chat?.regenerate(message: message)
        }
    }
}

#Preview {
    VStack {
        MessageMenu(message: .mockUserMessage, isExpanded: .constant(true))
        MessageMenu(message: .mockAssistantMessage, isExpanded: .constant(true))
    }
    .frame(width: 500)
    .padding()
}
