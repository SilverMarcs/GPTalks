//
//  SavedConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/12/2023.
//

import SwiftUI

struct SavedConversationList: View {
    @Binding var savedConversations: [SavedConversation]

    var body: some View {
        List(savedConversations) { conversation in
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
            .navigationTitle("Saved")
        }
    }
    
    public func saveConversation(conversation: SavedConversation) {
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
    let title: String
}
