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
    
    var body: some View {
        NavigationLink(value: session) {
            HStack(spacing: 10) {
                Image(session.configuration.service.iconName)
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(imagePadding)
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
                    .frame(maxHeight: 20)
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
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                deleteDialogueHandler(session)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    
    let imageSize: CGFloat = {
       #if os(iOS)
       return 44
       #elseif os(macOS)
       return 36
       #endif
    }()

    let  imagePadding: CGFloat = {
       #if os(iOS)
       return 22
       #elseif os(macOS)
       return 11
       #endif
    }()

    let titleFont: Font = {
       #if os(iOS)
       return Font.system(.headline)
       #elseif os(macOS)
       return Font.system(.body)
       #endif
    }()
    
    let lastMessageFont: Font = {
        #if os(iOS)
        return Font.system(.subheadline)
        #elseif os(macOS)
        return Font.system(.body)
        #endif
    }()

    let textLineLimit: Int = {
       #if os(iOS)
       return 2
       #elseif os(macOS)
       return 1
       #endif
    }()
}

