//
//  ConversationMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct ConversationMenu: View {
    @Environment(ChatSessionVM.self) var sessionVM
    @Environment(\.isQuick) var isQuick
    
    var group: ConversationGroup
    
    @Binding var isExpanded: Bool
    var toggleTextSelection: (() -> Void)? = nil
    
    @State var isCopied = false
    @State var isForking = false

    var body: some View {
        #if os(macOS)
            HStack {
                buttons
                    .labelStyle(.iconOnly)
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
            #if !os(macOS)
            selectText
            #endif
        }

        Section {
            resetContext
            
            forkSession
        }
        
        Section {
            deleteGroup
        }
        
        navigate
    }
    
    @ViewBuilder
    var editGroup: some View {
        if !isQuick && group.role == .user {
            HoverScaleButton(icon: "pencil.and.outline", label: "Edit") {
                group.setupEditing()
            }
            .help("Edit")
        }
    }
    
    @ViewBuilder
    var expandHeight: some View {
        if group.role == .user {
            HoverScaleButton(icon: isExpanded ? "arrow.up.right.and.arrow.down.left" : "arrow.down.left.and.arrow.up.right", label: isExpanded ? "Collapse" : "Expand") {
                withAnimation {
                    isExpanded.toggle()
                    group.session?.proxy?.scrollTo(group, anchor: .top)
                }
            }
            .contentTransition(.symbolEffect(.replace))
            .help("Expand")
        }
    }

    var resetContext: some View {
        HoverScaleButton(icon: "eraser", label: "Reset Context") {
            group.resetContext()
        }
    }

    @ViewBuilder
    var forkSession: some View {
        if isForking {
            ProgressView()
                .controlSize(.small)
        } else {
            HoverScaleButton(icon: "arrow.branch", label: "Fork Session") {
                isForking = true
                Task {
                    if let newSession = await group.session?.copy(from: group, purpose: .chat) {
                        sessionVM.fork(newSession: newSession)
                        isForking = false
                    }
                }
            }
        }
    }

    var copyText: some View {
        HoverScaleButton(icon: isCopied ? "checkmark" : "paperclip", label: "Copy Text") {
            group.activeConversation.content.copyToPasteboard()
            
            isCopied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isCopied = false
            }
        }
        .contentTransition(.symbolEffect(.replace))
    }
    
    var selectText: some View {
        Button {
            toggleTextSelection?()
        } label: {
            Label("Select Text", systemImage: "text.cursor")
                .help("Select Text")
        }
    }

    var deleteGroup: some View {
        HoverScaleButton(icon: "minus.circle", label: "Delete") {
            group.deleteSelf()
        }
    }

    var regenGroup: some View {
        HoverScaleButton(icon: "arrow.2.circlepath", label: "Regenerate") {
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
    }

    var navigate: some View {
        var canNavigateLeft: Bool {
            guard let session = group.session else { return false }
            let groups = session.groups
            if let indexOfCurrentGroup = groups.firstIndex(where: { $0.id == group.id }) {
                if groups.count >= 2 && indexOfCurrentGroup >= groups.count - 2 {
                    return group.conversations.count > 1 && group.canGoLeft
                }
            }
            return false
        }
        
        var canNavigateRight: Bool {
            guard let session = group.session else { return false }
            let groups = session.groups
            if let indexOfCurrentGroup = groups.firstIndex(where: { $0.id == group.id }) {
                if groups.count >= 2 && indexOfCurrentGroup >= groups.count - 2 {
                    return group.conversations.count > 1 && group.canGoRight
                }
            }
            return false
        }
        
        var shouldShowButtons: Bool {
            guard let session = group.session else { return false }
            let groups = session.groups
            if let indexOfCurrentGroup = groups.firstIndex(where: { $0.id == group.id }) {
                return groups.count >= 2 && indexOfCurrentGroup >= groups.count - 2
            }
            return false
        }
        
        return Group {
            #if os(macOS)
            if group.conversations.count > 1 && group.role == .assistant {
                HoverScaleButton(icon: "chevron.left", label: "Previous") {
                    group.setActiveToLeft()
                }
                .disabled(!shouldShowButtons || !canNavigateLeft)
                .help("Previous")
                
                HoverScaleButton(icon: "chevron.right", label: "Next") {
                    group.setActiveToRight()
                }
                .disabled(!shouldShowButtons || !canNavigateRight)
                .help("Next")
            }
            #else
            if group.conversations.count > 1 && group.role == .assistant {
                Section("Iterations: \(group.activeConversationIndex + 1)/\(group.conversations.count)") {
                    HoverScaleButton(icon: "chevron.left", label: "Previous") {
                        group.setActiveToLeft()
                    }
                    .disabled(!shouldShowButtons || !canNavigateLeft)
                    
                    HoverScaleButton(icon: "chevron.right", label: "Next") {
                        group.setActiveToRight()
                    }
                    .disabled(!shouldShowButtons || !canNavigateRight)
                }
            }
            #endif
        }
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
