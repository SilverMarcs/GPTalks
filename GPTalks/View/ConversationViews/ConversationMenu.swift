//
//  ConversationMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct ConversationMenu: View {
    var group: ConversationGroup
    @Environment(\.modelContext) var modelContext

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
            regenButton

            copyButton

            resetContext

            forkButton

            deleteConversation

            if group.conversations.count > 1 {
                navigationButtons
            }
        }
    }

    var resetContext: some View {
        Button {
            group.resetContext()
        } label: {
            Label("Reset Context", systemImage: "eraser")
        }
    }

    var forkButton: some View {
        Button {
            if let newSession = group.session?.fork(from: group) {
                withAnimation {
                    modelContext.insert(newSession)
                }
            }
            do {
                try modelContext.save()
            } catch {
                print("Failed to save session: \(error)")
            }
        } label: {
            Label("Fork Session", systemImage: "arrow.branch")
        }
    }

    var copyButton: some View {
        Button {
            group.activeConversation.content.copyToPasteboard()
        } label: {
            Label("Copy", systemImage: "paperclip")
        }
    }

    var deleteConversation: some View {
        Button {
            withAnimation {
                group.deleteSelf()
            }
        } label: {
            Label("Delete", systemImage: "minus.circle")
        }
    }

    var regenButton: some View {
        Button {
            group.session?.regenerateLast()
        } label: {
            Label("Regenerate", systemImage: "arrow.2.circlepath")
        }
    }

    var navigationButtons: some View {
        Group {
            Button {
                group.setActiveToLeft()
            } label: {
                Label("Previous", systemImage: "chevron.left")
            }
            .disabled(group.canGoLeft == false)

            Text(
                "\(group.activeConversationIndex + 1)/\(group.conversations.count)"
            )
            .foregroundStyle(.secondary)
            .frame(width: 30)

            Button {
                group.setActiveToRight()
            } label: {
                Label("Next", systemImage: "chevron.right")
            }
            .disabled(group.canGoRight == false)
        }
    }
}

#Preview {
    let session = Session()

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
    .frame(width: 500)
    .padding()
}
