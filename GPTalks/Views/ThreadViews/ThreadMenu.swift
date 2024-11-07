//
//  ThreadMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct ThreadMenu: View {
    @Environment(ChatVM.self) private var sessionVM
    @Environment(\.isQuick) private var isQuick
    @Environment(\.providers) var providers
    
    var thread: Thread
    
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
            .frame(height: 20)
        #else
            buttons
        #endif
    }

    @ViewBuilder
    var buttons: some View {
        expandHeight
        
        Section {
            editGroup
            
            regenGroup
        }
    
        Section {
            copyText
            
            forkSession
            #if !os(macOS)
            selectText
            #endif
        }
        
        Section {
            deleteGroup
        }
    }
    
    @ViewBuilder
    var editGroup: some View {
        if !isQuick && thread.role == .user {
            Button {
                thread.chat?.inputManager.setupEditing(thread: thread)
            } label: {
                Label("Edit", systemImage: "pencil.and.outline")
            }
            .help("Edit")
        }
    }
    
    @ViewBuilder
    var expandHeight: some View {
        if thread.role == .user {
            Button {
                isExpanded.toggle()
                thread.chat?.proxy?.scrollTo(thread, anchor: .bottom)
            } label: {
                Label(isExpanded ? "Collapse" : "Expand", systemImage: isExpanded ? "arrow.up.right.and.arrow.down.left" : "arrow.down.left.and.arrow.up.right")
            }
            .contentTransition(.symbolEffect(.replace))
            .help("Expand")
        }
    }

    @ViewBuilder
    var forkSession: some View {
        if isForking {
            ProgressView()
                .controlSize(.small)
        } else {
            Button {
                isForking = true
                Task {
                    if let newChat = await thread.chat?.copy(from: thread, purpose: .chat) {
                        sessionVM.fork(newChat: newChat)
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
            thread.content.copyToPasteboard()
            
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

    var deleteGroup: some View {
        Button(role: .destructive) {
            thread.chat?.deleteThread(thread)
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

    var regenGroup: some View {
        #if os(macOS)
        Menu {
            ForEach(providers) { provider in
                Menu {
                    ForEach(provider.chatModels) { model in
                        Button(model.name) {
                            thread.chat?.config.provider = provider
                            thread.chat?.config.model = model
                            
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
            await thread.chat?.regenerate(thread: thread)
        }
    }
}

#Preview {
    VStack {
        ThreadMenu(thread: .mockUserThread, isExpanded: .constant(true))
        ThreadMenu(thread: .mockAssistantThread, isExpanded: .constant(true))
    }
    .frame(width: 500)
    .padding()
}
