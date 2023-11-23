//
//  DialogueSessionListView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/17.
//

import SwiftUI

struct DialogueSessionListView: View {
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
            DialogueListItem(session: session) { _ in
                deleteDialogueHandler(session)
                if let firstDialogue = dialogueSessions.first {
                    selectedDialogueSession = firstDialogue
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
    }
}




