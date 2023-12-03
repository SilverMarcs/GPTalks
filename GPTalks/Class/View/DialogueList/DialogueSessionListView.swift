//
//  DialogueSessionListView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI
import CoreData

struct DialogueSessionListView: View {
    @State private var searchQuery = ""
    #if os(iOS)
        @State var isShowSettingView = false
    #endif

    @Binding var dialogueSessions: [DialogueSession]
    @Binding var selectedDialogueSession: DialogueSession?

    @State var showSavedConversations = false
    
    @State var savedConversations: [SavedConversation] = []

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
                    savedlistLink
                }
                .safeAreaPadding(.bottom, 8)
            #else
                VStack {
                    if !filteredDialogueSessions.isEmpty {
                        savedlistLink
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
        .onAppear {
            savedConversations = fetchConversations()
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
                SavedConversationList(savedConversations: $savedConversations)
            } else {
                list
            }
        #else
            list
        #endif
    }
    
    var list: some View {
        List {
            ForEach(filteredDialogueSessions, id: \.id) { session in
                NavigationLink(
                    destination: MessageListView(session: session, saveConversation: saveConversation),
                    tag: session,
                    selection: $selectedDialogueSession)
                {
                    DialogueListItem(session: session, deleteDialogue: deleteDialogue)
                }
            }
        }
    }

    @State var isSelected = false

    var savedlistLink: some View {
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
                SavedConversationList(savedConversations: $savedConversations)
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
    
    private func saveConversation(conversation: SavedConversation) {
        // Check if the conversation id already exists in the savedConversations array
        if !savedConversations.contains(where: { $0.id == conversation.id }) {
            savedConversations.insert(conversation, at: 0)
            
            let context = PersistenceController.shared.container.viewContext
            let savedConversationData = SavedConversationData(context: context)
            savedConversationData.id = conversation.id
            savedConversationData.date = conversation.date
            savedConversationData.content = conversation.content
            savedConversationData.title = conversation.title

            do {
                try PersistenceController.shared.save()
            } catch {
                print("Failed to save conversation: \(error)")
            }
        } else {
            print("Conversation with id \(conversation.id) already exists.")
        }
    }

    
    func fetchConversations() -> [SavedConversation] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest = NSFetchRequest<SavedConversationData>(entityName: "SavedConversationData")

        do {
            let results = try context.fetch(fetchRequest)
            return results.map { SavedConversation(id: $0.id!, date: $0.date!, content: $0.content!, title: $0.title!) }
        } catch {
            print("Failed to fetch conversations: \(error)")
            return []
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
