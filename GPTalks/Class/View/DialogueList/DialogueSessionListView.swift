//
//  DialogueSessionListView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/17.
//

import SwiftUI

struct DialogueSessionListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showRenameDialog = false
    @State private var newName = ""
    @State private var sessionToRename: DialogueSession?
    @State private var searchQuery = ""
    
#if os(iOS)
    @Environment(\.verticalSizeClass) var verticalSizeClass

    private var shouldShowIcon: Bool {
        verticalSizeClass != .compact
    }
#endif

    @Binding var dialogueSessions: [DialogueSession]
    @Binding var selectedDialogueSession: DialogueSession?
    
    @Binding var isReplying: Bool
    
    var deleteHandler: (IndexSet) -> Void
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
        List(selection: $selectedDialogueSession) {
            ForEach(filteredDialogueSessions) { session in
                list(session: session)
                    .contextMenu {
                        Button {
                            sessionToRename = session
                            showRenameDialog = true
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
            .onDelete { indexSet in
                deleteHandler(indexSet)
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
        .alert("Rename", isPresented: $showRenameDialog, actions: {
            TextField("Enter new name", text: $newName)
            // TODO do all thsi inside session itself
            Button("Rename", action: {
                if let session = sessionToRename {
                    session.rename(newTitle: newName)
                    do {
                        try viewContext.save()
                    } catch {
                        print("Failed to save the changes: \(error)")
                    }
                }
            })
            Button("Cancel", role: .cancel, action: {})
        })
    }
    
    private func list(session: DialogueSession) -> some View {
#if os(iOS)
        iosList(session: session)
#else
        macosList(session: session)
#endif
    }
    
#if os(iOS)
    private func iosList(session: DialogueSession) -> some View {
        HStack {
            if shouldShowIcon {
                Image("openai")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .cornerRadius(22)
                    .padding(.leading, 3)
                    .padding(.trailing, 8)
            }
            VStack(spacing: 4) {
                NavigationLink(value: session) {
                    HStack {
                        Text(session.title)
                            .bold()
                            .font(Font.system(.headline))
                            .lineLimit(1)
                        Spacer()
                        Text(session.configuration.model.name)
                            .font(Font.system(.subheadline))
                    }
                }
                HStack {
                    Text(session.lastMessage)
                        .font(Font.system(.subheadline))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        )
                }
                .frame(height: 41)
            }
        }
    }
#endif
    
    private func macosList(session: DialogueSession) -> some View {
        NavigationLink(value: session) {
            HStack {
                Image(session.service.provider.iconName)
                    .resizable()
                    .frame(width: 34, height: 34)
                    .cornerRadius(11)
                    .padding(.leading, 5)
                    .padding(.trailing, 3)
                VStack {
                    HStack {
                        Text(session.title)
                            .bold()
                            .font(Font.system(.headline))
                        Spacer()
                        Text(session.configuration.model.name)
                            .font(Font.system(.subheadline))
                    }
                    .padding(.bottom, -1)
                    HStack {
//                        if session.isReplying {
//                            VStack(alignment: .leading) {
//                                ReplyingIndicatorView()
//                                    .frame(height: 15, alignment: .leading)
//                                    .lineLimit(1)
//                            }
//                        } else {
                            Text(session.lastMessage)
                                .font(Font.system(.body))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity,
                                    alignment: .leading
                                )
//                        }
                    }
                }
                .padding(.vertical, 10)
            }
        }
    }
    
    
    private func updateList() {
        withAnimation {
            if selectedDialogueSession != nil {
                let session = selectedDialogueSession
                sortList()
                selectedDialogueSession = session
            } else {
                sortList()
            }
        }
    }
    
    private func sortList() {
        dialogueSessions = dialogueSessions.sorted(by: {
            $0.date > $1.date
        })
    }
}


extension Date {
    
    var dialogueDesc: String {
        if self.isInYesterday {
            return String(localized: "Yesterday")
        }
        if self.isInToday {
            return timeString(ofStyle: .short)
        }
        return dateString(ofStyle: .short)
    }
}

import Combine

extension Published.Publisher {
    var didSet: AnyPublisher<Value, Never> {
        // Any better ideas on how to get the didSet semantics?
        // This works, but I'm not sure if it's ideal.
        self.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
}
