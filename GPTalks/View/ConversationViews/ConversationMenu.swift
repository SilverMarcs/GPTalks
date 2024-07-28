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
    
    @Query var sessions: [Session]
    
    var labelSize: CGSize? = nil
    var toggleMaxHeight: (() -> Void)? = nil
    var isExpanded: Bool = false
    var toggleTextSelection: (() -> Void)? = nil

    var body: some View {
        #if os(macOS)
            HStack(spacing: 0) {
                buttons
                    .buttonStyle(HoverSquareBackgroundStyle())
            }
        #else
            buttons
        #endif
    }

    var buttons: some View {
        Group {
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
    }
    
    @ViewBuilder
    var editGroup: some View {
        if group.role == .user {
            Button {
                group.setupEditing()
            } label: {
                Label("Edit", systemImage: "pencil.and.outline")
                    .help("Edit")
            }
        }
    }
    
    @ViewBuilder
    var expandHeight: some View {
        if let labelSize = labelSize, labelSize.height >= 400 {
            Button {
                toggleMaxHeight?()
                withAnimation {
                    group.session?.proxy?.scrollTo(group, anchor: .top)
                }
            } label: {
                Label(isExpanded ? "Collapse" : "Expand",
                      systemImage: isExpanded ? "arrow.up.right.and.arrow.down.left" : "arrow.down.left.and.arrow.up.right")
                .help("Expand")
            }
        }
    }

    var resetContext: some View {
        Button {
            group.resetContext()
        } label: {
            Label("Reset Context", systemImage: "eraser")
                .help("Reset Context")
        }
    }

    var forkSession: some View {
        Button {
            if let newSession = group.session?.copy(from: group, title: "Forked Session") {
                sessionVM.fork(session: newSession, sessions: sessions, modelContext: modelContext)
            }
        } label: {
            Label("Fork Session", systemImage: "arrow.branch")
                .help("Fork Session")
        }
    }

    var copyText: some View {
        Button {
            group.activeConversation.content.copyToPasteboard()
        } label: {
            Label("Copy Text", systemImage: "paperclip")
                .help("Copy Text")
        }
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
        Button(role: .destructive) {
            withAnimation {
                group.deleteSelf()
            }
        } label: {
            Label("Delete", systemImage: "minus.circle")
                .help("Delete")
        }
    }

    @ViewBuilder
    var regenGroup: some View {
        Button {
            if group.role == .assistant {
                group.session?.regenerate(group: group)
            } else if group.role == .user {
                group.setupEditing()
                Task {
                    await group.session?.sendInput()
                }
            }
        } label: {
            Label("Regenerate", systemImage: "arrow.2.circlepath")
                .help("Regenerate")
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
                Button {
                    group.setActiveToLeft()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                        .help("Previous")
                }
                .disabled(!shouldShowButtons || !canNavigateLeft)
                
                Text(
                    "\(group.activeConversationIndex + 1)/\(group.conversations.count)"
                )
                .foregroundStyle(.secondary)
                .frame(width: 30)
                
                Button {
                    group.setActiveToRight()
                } label: {
                    Label("Next", systemImage: "chevron.right")
                        .help("Next")
                }
                .disabled(!shouldShowButtons || !canNavigateRight)
            }
            #else
            if group.conversations.count > 1 && group.role == .assistant {
                Section("Iterations: \(group.activeConversationIndex + 1)/\(group.conversations.count)") {
                    Button {
                        group.setActiveToLeft()
                    } label: {
                        Label("Previous", systemImage: "chevron.left")
                    }
                    .disabled(!shouldShowButtons || !canNavigateLeft)
                    
                    Button {
                        group.setActiveToRight()
                    } label: {
                        Label("Next", systemImage: "chevron.right")
                    }
                    .disabled(!shouldShowButtons || !canNavigateRight)
                }
            }
            #endif
        }
    }
}

#Preview {
    let config = SessionConfig()
    let session = Session(config: config)

    let userConversation = Conversation(role: .user, content: "Hello, World!")
    let assistantConversation = Conversation(
        role: .assistant, content: "Hello, World!")

    let group = ConversationGroup(
        conversation: userConversation, session: session)
    group.addConversation(
        Conversation(role: .user, content: "This is second."))
    group.addConversation(
        Conversation(role: .user, content: "This is third message."))
    let group2 = ConversationGroup(
        conversation: assistantConversation, session: session)

    return VStack {
        ConversationGroupView(group: group)
        ConversationGroupView(group: group2)
    }
    .environment(SessionVM())
    .frame(width: 500)
    .padding()
}
