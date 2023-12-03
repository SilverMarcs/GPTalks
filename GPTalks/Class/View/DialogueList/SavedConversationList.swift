//
//  SavedConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/12/2023.
//

import SwiftUI

struct SavedConversationList: View {
    @Binding var savedConversations: [SavedConversation]
    
    var delete: (IndexSet) -> Void
    var rename: (UUID, String) -> Void
    
    @State private var isRenameAlertPresented = false
    @State private var newName = ""

    var body: some View {
        List {
            ForEach(savedConversations, id: \.id) { conversation in
                NavigationLink(destination: MessageView(conversation: conversation).background(.background)) {
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
                }
                .contextMenu {
                    Button(action: {
                        isRenameAlertPresented = true
                    }) {
                        Text("Rename")
                    }
                }
                .alert("Rename Save", isPresented: $isRenameAlertPresented) {
                    TextField("Enter new name", text: $newName)
                    Button("Rename", action: {
                        //rename logic here
                    })
                    Button("Cancel", role: .cancel, action: {}
                    )
                }
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Saved")
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
    var conversation: SavedConversation

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

struct SavedConversation: Identifiable {
    let id: UUID
    let date: Date
    let content: String
    var title: String
}
