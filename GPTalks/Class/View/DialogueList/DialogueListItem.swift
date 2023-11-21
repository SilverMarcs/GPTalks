//
//  ListItem.swift
//  GPTalks
//
//  Created by Zabir Raihan on 13/11/2023.
//

import SwiftUI

struct ListItem: View {
    @State private var showRenameDialogue = false
    @State private var newName = ""
    @State private var sessionToRename: DialogueSession?
    @State private var searchQuery = ""

    @ObservedObject var session: DialogueSession
    var deleteDialogueHandler: (DialogueSession) -> Void
    var sessionResetter: () -> Void

    var body: some View {
        NavigationLink(value: session) {
            HStack(spacing: 10) {
                Image(session.configuration.provider.iconName)
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(imageRadius)
                VStack(spacing: 8) {
                    HStack {
                        Text(session.title)
                            .bold()
                            .font(titleFont)
                            .lineLimit(1)
                        Spacer()
                        Text(session.configuration.model.name)
                            .font(Font.system(.subheadline))
                    }
                    VStack {
                        if session.isReplying() {
                            ReplyingIndicatorView()
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: 14,
                                    alignment: .leading
                                )
                        } else {
                            Text(session.lastMessage)
                                .font(lastMessageFont)
                                .foregroundColor(.secondary)
                                .lineLimit(textLineLimit)
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity,
                                    alignment: .leading
                                )
                        }
                    }
                    .frame(maxHeight: lastMessageMaxHeight)
                }
            }
        }
        .frame(minHeight: 40)
        .padding(.vertical, 7)
        .padding(.horizontal, 5)
        .alert("Rename", isPresented: $showRenameDialogue, actions: {
            TextField("Enter new name", text: $newName)
            Button("Rename", action: {
                if let session = sessionToRename {
                    session.rename(newTitle: newName)
                }
            })
            Button("Cancel", role: .cancel, action: {})
        })
        .contextMenu {
            Button {
                sessionToRename = session
                newName = session.title
                showRenameDialogue = true
            } label: {
                HStack {
                    Image(systemName: "pencil")
                    Text("Rename")
                }
            }
            
            Button(role: .destructive) {
                deleteDialogueHandler(session)
                sessionResetter()
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                deleteDialogueHandler(session)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var lastMessageMaxHeight: CGFloat {
        #if os(iOS)
            40
        #elseif os(macOS)
            20
        #endif
    }
    
    private var imageSize: CGFloat {
        #if os(iOS)
            44
        #elseif os(macOS)
            36
        #endif
    }

    private var imageRadius: CGFloat {
        #if os(iOS)
            16
        #elseif os(macOS)
            11
        #endif
    }

    private var titleFont: Font {
        #if os(iOS)
            Font.system(.headline)
        #elseif os(macOS)
            Font.system(.body)
        #endif
    }

    private var lastMessageFont: Font {
        #if os(iOS)
            Font.system(.subheadline)
        #elseif os(macOS)
            Font.system(.body)
        #endif
    }

    private var textLineLimit: Int {
        #if os(iOS)
            2
        #elseif os(macOS)
            1
        #endif
    }
}
