//
//  DialogueSessionListView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/17.
//

import SwiftUI

struct DialogueSessionListView: View {
    @State private var showRenameDialogue = false
    @State private var newName = ""
    @State private var sessionToRename: DialogueSession?
    @State private var searchQuery = ""

    @Binding var dialogueSessions: [DialogueSession]
    @Binding var selectedDialogueSession: DialogueSession?
    
    var deleteDialogueHandler: (DialogueSession) -> Void

    var filteredDialogueSessions: [DialogueSession] {
        if searchQuery.isEmpty {
            return dialogueSessions
        } else {
            var filteredSessions: [DialogueSession] = []
            for session in dialogueSessions {
                if session.title.localizedCaseInsensitiveContains(searchQuery) {
                    filteredSessions.append(session)
                }
            }
            return filteredSessions
        }
    }
    
    var body: some View {
        List(filteredDialogueSessions, selection: $selectedDialogueSession) { session in
            listItem(session: session)
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
                        if session == selectedDialogueSession {
                            selectedDialogueSession = nil
                        }
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                    }
            }
        }
        .searchable(text: $searchQuery)
#if os(iOS)
        .listStyle(.plain)
        .navigationTitle("Chats")
        .navigationBarTitleDisplayMode(.large)
#else
        .frame(minWidth: 290)
#endif
        .alert("Rename", isPresented: $showRenameDialogue, actions: {
            TextField("Enter new name", text: $newName)
            Button("Rename", action: {
                if let session = sessionToRename {
                    session.rename(newTitle: newName)
                }
            })
            Button("Cancel", role: .cancel, action: {})
        })
    }
    
    private func listItem(session: DialogueSession) -> some View {
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

           .padding(.vertical, 7)
           .padding(.horizontal, 5)
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




