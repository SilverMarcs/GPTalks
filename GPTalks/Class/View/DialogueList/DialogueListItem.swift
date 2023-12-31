//
//  DialogueListItem.swift
//  GPTalks
//
//  Created by Zabir Raihan on 13/11/2023.
//

import SwiftUI

struct DialogueListItem: View {
    @EnvironmentObject var viewModel: DialogueViewModel
    
    @ObservedObject var session: DialogueSession
    
    @State private var showRenameDialogue = false
    @State private var showDeleteDialogue = false
    @State private var newName = ""
    @State private var sessionToRename: DialogueSession?
    @State private var searchQuery = ""

    var body: some View {
        HStack(spacing: imgToTextSpace) {
            session.configuration.provider.logoImage
            VStack(spacing: 8) {
                HStack {
                    Text(session.title)
                        .bold()
                        .font(titleFont)
                        .lineLimit(1)
                    Spacer()
                    Text(session.configuration.model.name)
                        .font(.subheadline)
                        .opacity(0.9)
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
                            .foregroundStyle(.secondary)
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
        .frame(minHeight: minHeight)
        .alert("Rename Session", isPresented: $showRenameDialogue, actions: {
            TextField("Enter new name", text: $newName)
            Button("Rename", action: {
                if let session = sessionToRename {
                    session.rename(newTitle: newName)
                }
            })
            Button("Cancel", role: .cancel, action: {})
        })
        .alert("Confirm Delete?", isPresented: $showDeleteDialogue, actions: {
            Button("Delete", role: .destructive, action: {
                viewModel.deleteDialogue(session)
                showDeleteDialogue = false
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
            
#if os(macOS)
            Button {
                viewModel.toggleArchive(session: session)
            } label: {
                HStack {
                    Image(systemName: "archivebox")
                    Text(session.isArchive ? "Unarchive" : "Archive")
                }
            }
            #endif
            
            Button(role: .destructive) {
                showDeleteDialogue = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
        }
        .swipeActions(edge: .trailing) {
            #if os(macOS)
            Button {
                viewModel.toggleArchive(session: session)
            } label: {
                Label(session.isArchive ? "Unarchive" : "Archive", systemImage: session.isArchive ? "archivebox" : "archivebox.fill")
            }
            .tint(.orange)
            #endif
            
            Button(role: .destructive) {
                viewModel.deleteDialogue(session)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
        }
        .swipeActions(edge: .leading) {
            Button(role: .cancel) {
                sessionToRename = session
                newName = session.title
                showRenameDialogue.toggle()
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            .tint(.accentColor)
        }
    }
    
    private var minHeight: CGFloat {
        #if os(iOS)
            75
        #elseif os(macOS)
            55
        #endif
    }
    

    private var imgToTextSpace: CGFloat {
        #if os(iOS)
            13
        #elseif os(macOS)
            10
        #endif
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
            50
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
