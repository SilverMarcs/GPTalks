//
//  DialogueSessionListView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/17.
//

import SwiftUI

struct DialogueSessionListView: View {
    @State private var searchQuery = ""
#if os(iOS)
    @State var isShowSettingView = false
#endif

    @Binding var dialogueSessions: [DialogueSession]
    @Binding var selectedDialogueSession: DialogueSession?
    
    var deleteDialogue: (DialogueSession) -> Void
    var addDialogue: () -> Void

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
            NavigationLink(value: session) {
                DialogueListItem(session: session, deleteDialogue: deleteDialogue)
            }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isShowSettingView = true
                } label: {
                    Image(systemName: "gear")
                }
            }
#endif
            ToolbarItem {
                Spacer()
            }      
            ToolbarItem(placement: .automatic) {
                Button {
                    addDialogue()
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .searchable(text: $searchQuery)
#if os(macOS)
        .frame(minWidth: 290)
#else
        .listStyle(.plain)
        .navigationTitle("Chats")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $isShowSettingView) {
            AppSettingsView()
        }
#endif
    }
}




