//
//  ConversationMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct ConversationMenu: View {
    var group: ConversationGroup
    @Environment(\.modelContext) var modelContext
    @Environment(SessionVM.self) var sessionVM

    var providers: [Provider]
    
    @Binding var isExpanded: Bool
    var toggleTextSelection: (() -> Void)? = nil
    
    @State var isCopied = false

    var body: some View {
        #if os(macOS) || targetEnvironment(macCatalyst)
            HStack {
                buttons
                    .labelStyle(.iconOnly)
            }
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
        if group.role == .user {
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

    var forkSession: some View {
        HoverScaleButton(icon: "arrow.branch", label: "Fork Session") {
            if let newSession = group.session?.copy(from: group, purpose: .chat) {
                sessionVM.fork(session: newSession, modelContext: modelContext)
            }
        }
    }

    var copyText: some View {
        HoverScaleButton(icon: isCopied ? "checkmark" : "paperclip", label: "Copy Text") {
            isCopied = true
            group.activeConversation.content.copyToPasteboard()
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
        Menu {
            ForEach(providers) { provider in
                Menu {
                    ForEach(provider.chatModels.filter { $0.isEnabled }.sorted(by: { $0.order < $1.order })) { model in
                        Button {
                            group.session?.config.provider = provider
                            group.session?.config.model = model
                            Task { @MainActor in
                                await group.session?.regenerate(group: group)
                            }
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
            if group.role == .assistant {
                Task { @MainActor in
                    await group.session?.regenerate(group: group)
                }
            } else if group.role == .user {
                group.setupEditing()
                Task {
                    await group.session?.sendInput()
                }
            }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
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
            #if os(macOS) || targetEnvironment(macCatalyst)
            if group.conversations.count > 1 && group.role == .assistant {
                HoverScaleButton(icon: "chevron.left", label: "Previous") {
                    group.setActiveToLeft()
                }
                .disabled(!shouldShowButtons || !canNavigateLeft)
                .help("Previous")
                
//                Text(
//                    "\(group.activeConversationIndex + 1)/\(group.conversations.count)"
//                )
//                .foregroundStyle(.secondary)
//                .frame(width: 30)
                
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

//#Preview {
//    let config = SessionConfig()
//    let session = Session(config: config)
//
//    let userConversation = Conversation(role: .user, content: "Hello, World!")
//    let assistantConversation = Conversation(
//        role: .assistant, content: "Hello, World!")
//
//    let group = ConversationGroup(
//        conversation: userConversation, session: session)
//    group.addConversation(
//        Conversation(role: .user, content: "This is second."))
//    group.addConversation(
//        Conversation(role: .user, content: "This is third message."))
//    let group2 = ConversationGroup(
//        conversation: assistantConversation, session: session)
//
//    return VStack {
//        ConversationGroupView(group: group)
//        ConversationGroupView(group: group2)
//    }
//    .environment(SessionVM())
//    .frame(width: 500)
//    .padding()
//}
