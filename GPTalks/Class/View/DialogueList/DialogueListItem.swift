//
//  DialogueListItem.swift
//  GPTalks
//
//  Created by Zabir Raihan on 13/11/2023.
//

import SwiftUI

struct DialogueListItem: View {
    @Environment(DialogueViewModel.self) private var viewModel
    
    var session: DialogueSession
    
    @State private var showRenameDialogue = false
    @State private var newName = ""

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
                    #if !os(visionOS)
                    Text(session.configuration.model.name)
                        .font(.subheadline)
                        .opacity(0.9)
                    #endif
                }
                VStack {
                    if session.isReplying {
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
        .alert("Rename Session", isPresented: $showRenameDialogue) {
            TextField("Enter new name", text: $newName)
            Button("Rename") {
                session.rename(newTitle: newName)
            }
            Button("Cancel", role: .cancel) {
                showRenameDialogue = false
            }
        }
        .contextMenu {
            Group {
                renameButton
                
                archiveButton
                
                deleteButton
            }
            .labelStyle(.titleAndIcon)
        }
        .swipeActions(edge: .trailing) {
            deleteButton
            
            archiveButton
        }
        .swipeActions(edge: .leading) {
            renameButton
        }
    }
    
    var archiveButton: some View {
        Button {
            viewModel.toggleArchive(session: session)
        } label: {
            Label(session.isArchive ? "Unarchive" : "Archive", systemImage: "archivebox")
        }
        .tint(.orange)
    }
    
    var deleteButton: some View {
        Button(role: .destructive) {
            viewModel.deleteDialogue(session)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    var renameButton: some View {
        Button {
            print("Current session title: \(session.title)")
//            newName = session.title
            showRenameDialogue.toggle()
        } label: {
            Label("Rename", systemImage: "pencil")
        }
        .tint(.accentColor)
    }
    
    private var minHeight: CGFloat {
        #if os(macOS)
            55
        #else
            75
        #endif
    }
    

    private var imgToTextSpace: CGFloat {
        #if os(macOS)
        10
        #else
        13
        #endif
    }

    private var lastMessageMaxHeight: CGFloat {
        #if os(macOS)
        20
        #else
        40
        #endif
    }

    private var imageSize: CGFloat {
        #if os(macOS)
        36
        #else
        50
        #endif
    }

    private var imageRadius: CGFloat {
        #if os(macOS)
        11
        #else
        16
        #endif
    }

    private var titleFont: Font {
        #if os(macOS)
        Font.system(.body)
        #else
        Font.system(.headline)
        #endif
    }

    private var lastMessageFont: Font {
        #if os(macOS)
        Font.system(.body)
        #else
        Font.system(.subheadline)
        #endif
    }

    private var textLineLimit: Int {
        #if os(macOS)
        1
        #else
        2
        #endif
    }
}
