//
//  DialogueSessionListView.swift
//  GPTalks
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
    
    @State var showSavedConversations = false

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
        Group {
                #if os(macOS)
            Group {
                if dialogueSessions.isEmpty {
                    placeHolder
                } else {
                    dialoguelist
                }
                }

                .safeAreaInset(edge: .bottom) {
                    savedlistItem
                }
                .safeAreaPadding(.bottom, 8)
                #else
                VStack {
                    if !filteredDialogueSessions.isEmpty {
                        savedlistItem
                            .padding(.horizontal)
                    }
                    Divider()
                    if dialogueSessions.isEmpty {
                        placeHolder
                    } else {
                        dialoguelist
                    }
                    
                }
                #endif
            
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
    var dialoguelist: some View {
        #if os(macOS)
        if isSelected {
            SavedConversationList(dialogueSessions: $dialogueSessions)
        } else {
            List(filteredDialogueSessions, id: \.self, selection: $selectedDialogueSession) { session in
                NavigationLink(value: session) {
                    DialogueListItem(session: session, deleteDialogue: deleteDialogue)
                }
            }
        }
        #else
        List(filteredDialogueSessions) { session in
            NavigationLink {
               MessageListView(session: session)
                    .accentColor(session.configuration.provider.accentColor)
            } label: {
                DialogueListItem(session: session, deleteDialogue: deleteDialogue)
            }
        }
        #endif
    }

    @State var isSelected = false

    var savedlistItem: some View {
        #if os(macOS)
        Button {
            isSelected.toggle()
        } label: {
            HStack {
                Image(systemName: isSelected ? "bookmark.fill" : "bookmark")
                Text("Bookmarked Conversations")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding(7)
        }
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isSelected ? .secondary.opacity(0.25) : Color.clear)
        )
        .buttonStyle(.borderless)
        .foregroundStyle(.primary)
        .padding(.horizontal, horizontalPadding)
        #else
        NavigationLink {
            SavedConversationList(dialogueSessions: $dialogueSessions)
        } label: {
            HStack {
                Image(systemName: "bookmark")
                Text("Bookmarked Conversations")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding(7)
        }
        #endif
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
    
    private var horizontalPadding: CGFloat {
        #if os(iOS)
        15
        #else
        11
        #endif
    }
}
