//
//  SavedConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/12/2023.
//

import SwiftUI

struct SavedConversationList: View {
    @Binding var savedConversations: [SavedConversation]

    var delete: (SavedConversation) -> Void
    var renameConversation: (SavedConversation, String) -> Void

    @State var searchQuery = ""

    var filteredSavedConversations: [SavedConversation] {
        if searchQuery.isEmpty {
            return savedConversations
        } else {
            var filteredSessions: [SavedConversation] = []
            for savedConversation in savedConversations {
                if savedConversation.title.localizedCaseInsensitiveContains(searchQuery) {
                    filteredSessions.append(savedConversation)
                }
            }
            return filteredSessions
        }
    }

    var body: some View {
        List {
            ForEach(filteredSavedConversations, id: \.id) { conversation in
                NavigationLink(destination: MessageView(conversation: conversation).background(.background)) {
                    savedListItem(conversation: conversation, delete: delete, renameConversation: renameConversation)
                }
            }
        }
        .searchable(text: $searchQuery)
//        .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Saved")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

struct savedListItem: View {
    @ObservedObject var conversation: SavedConversation

    @State private var isRenameAlertPresented: Bool = false
    @State private var newName: String = ""

    var delete: (SavedConversation) -> Void
    var renameConversation: (SavedConversation, String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(conversation.title)
                .font(.body)
                .bold()
            Text(conversation.content)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .font(.body)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .leading
                )
        }
        .padding(3)
        .swipeActions(edge: .leading) {
            Button(action: {
                newName = conversation.title
                isRenameAlertPresented = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Rename")
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                delete(conversation)
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
        }
        .contextMenu {
            Button(action: {
                newName = conversation.title
                isRenameAlertPresented = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Rename")
                }
            }

            Button(role: .destructive) {
                delete(conversation)
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
        }
        .alert("Rename Save", isPresented: $isRenameAlertPresented) {
            TextField("Enter new name", text: $newName)
            Button("Rename", action: {
                renameConversation(conversation, newName)
                newName = ""
            })
            Button("Cancel", role: .cancel, action: {}
            )
        }
    }

    private var spacing: CGFloat {
        #if os(iOS)
            return 6
        #else
            return 8
        #endif
    }
}

struct MessageView: View {
    @ObservedObject var conversation: SavedConversation

    var body: some View {
        ScrollView {
            MessageMarkdownView(text: conversation.content)
                .textSelection(.enabled)
                .bubbleStyle(isMyMessage: false)
                .padding()
            Spacer()
        }
        .toolbar {
            Button {
                conversation.content.copyToPasteboard()
            } label: {
                Text("Copy")
            }
        }
        .navigationTitle(conversation.title)
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .background(.background)
    }
}

class SavedConversation: Identifiable, ObservableObject {
    let id: UUID
    let date: Date
    let content: String
    @Published var title: String

    init(id: UUID, date: Date, content: String, title: String) {
        self.id = id
        self.date = date
        self.content = content
        self.title = title
    }
}
