//
//  ConversationMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct ConversationMenu: View {
    @Environment(ChatSessionVM.self) private var sessionVM
    @Environment(\.isQuick) private var isQuick
    @Environment(\.providers) var providers
    
    var group: ConversationGroup
    
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
        
        navigate
    }
    
    @ViewBuilder
    var editGroup: some View {
        if !isQuick && group.role == .user {
            Button {
                group.setupEditing()
            } label: {
                Label("Edit", systemImage: "pencil.and.outline")
            }
            .help("Edit")
        }
    }
    
    @ViewBuilder
    var expandHeight: some View {
        if group.role == .user {
            Button {
                isExpanded.toggle()
                group.session?.proxy?.scrollTo(group, anchor: .bottom)
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
                    if let newSession = await group.session?.copy(from: group, purpose: .chat) {
                        sessionVM.fork(newSession: newSession)
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
            group.activeConversation.content.copyToPasteboard()
            
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
        Button {
            group.deleteSelf()
        } label: {
            Label("Delete", systemImage: "minus.circle")
        }
        .help("Delete")
    }

    var regenGroup: some View {
        Menu {
            ForEach(providers) { provider in
                Menu {
                    ForEach(provider.chatModels) { model in
                        Button {
                            group.session?.config.provider = provider
                            group.session?.config.model = model
                            
                            regen()
                        } label: {
                            Text(model.name)
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
    }
        
        func regen() {
            if group.role == .assistant {
                Task { @MainActor in
                    await group.session?.regenerate(group: group)
                }
            } else if group.role == .user {
                group.setupEditing()
                Task { @MainActor in
                    await group.session?.sendInput()
                }
            }
        }

    @ViewBuilder
    var navigate: some View {
//        var canNavigateLeft: Bool {
//            guard let session = group.session else { return false }
//            let groups = session.groups
//            if let indexOfCurrentGroup = groups.firstIndex(where: { $0.id == group.id }) {
//                if groups.count >= 2 && indexOfCurrentGroup >= groups.count - 2 {
//                    return group.conversations.count > 1 && group.canGoLeft
//                }
//            }
//            return false
//        }
//        
//        var canNavigateRight: Bool {
//            guard let session = group.session else { return false }
//            let groups = session.groups
//            if let indexOfCurrentGroup = groups.firstIndex(where: { $0.id == group.id }) {
//                if groups.count >= 2 && indexOfCurrentGroup >= groups.count - 2 {
//                    return group.conversations.count > 1 && group.canGoRight
//                }
//            }
//            return false
//        }
//        
//        var shouldShowButtons: Bool {
//            guard let session = group.session else { return false }
//            let groups = session.groups
//            if let indexOfCurrentGroup = groups.firstIndex(where: { $0.id == group.id }) {
//                return groups.count >= 2 && indexOfCurrentGroup >= groups.count - 2
//            }
//            return false
//        }
        
//        return Group {
        #if os(macOS)
        if group.conversations.count > 1 && group.role == .assistant {
            Button {
                group.setActiveToLeft()
            } label: {
                Label("Previous", systemImage: "chevron.left")
            }
//                .disabled(!shouldShowButtons || !canNavigateLeft)
            .help("Previous")
            
            Button {
                group.setActiveToRight()
            } label: {
                Label("Next", systemImage: "chevron.right")
            }
//                .disabled(!shouldShowButtons || !canNavigateRight)
            .help("Next")
        }
        #else
        if group.conversations.count > 1 && group.role == .assistant {
            Section("Iterations: \(group.activeConversationIndex + 1)/\(group.conversations.count)") {
                Button {
                    group.setActiveToLeft()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }
//                    .disabled(!shouldShowButtons || !canNavigateLeft)
                
                Button {
                    group.setActiveToRight()
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
//                    .disabled(!shouldShowButtons || !canNavigateRight)
            }
        }
        #endif
        
    }
}

#Preview {
    VStack {
        ConversationMenu(group: .mockUserConversationGroup, isExpanded: .constant(true))
        ConversationMenu(group: .mockAssistantConversationGroup, isExpanded: .constant(true))
    }
    .frame(width: 500)
    .padding()
}
