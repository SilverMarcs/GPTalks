//
//  DialogueSessionListView.swift
//  ChatGPT
//
//  Created by Zabir Raihan on 27/11/2024.
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
        VStack {
            if dialogueSessions.isEmpty {
                placeHolder
            } else {
                list
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
    
    @ViewBuilder
    var list: some View {
        List(filteredDialogueSessions, selection: $selectedDialogueSession) { session in
            NavigationLink(value: session) {
                DialogueListItem(session: session, deleteDialogue: deleteDialogue)
            }
        }
    }
    
    @ViewBuilder
    var placeHolder: some View {
        if dialogueSessions.isEmpty {
            VStack {
                Spacer()
                Image(systemName: "message.fill")
                    .font(.system(size: 50))
                    .padding()
                    .foregroundColor(.secondary)
                Text("No Message")
                    .font(.title3)
                    .bold()
                Spacer()
            }
        }
    }
}




