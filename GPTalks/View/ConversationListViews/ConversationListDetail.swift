//
//  ConversationListExt.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct ConversationListDetail: View {
    @Environment(SessionVM.self) private var sessionVM
    
    var providers: [Provider]
    
    var body: some View {
        if sessionVM.state == .images && sessionVM.imageSelections.count == 1{
            if let imageSession = sessionVM.imageSelections.first {
                ImageGenerationList(session: imageSession)
                .id(imageSession.id)
            }
        } else if sessionVM.state == .chats && sessionVM.selections.count == 1 {
            if let chatSession = sessionVM.selections.first {
                ConversationList(session: chatSession, providers: providers)
                    .id(chatSession.id)
            }
        } else {
            VStack {
                if sessionVM.state == .chats && sessionVM.selections.count > 1 {
                    Text(String(sessionVM.selections.count) + " Items Selected")
                } else if sessionVM.state == .images && sessionVM.imageSelections.count > 1 {
                    Text(String(sessionVM.imageSelections.count) + " Items Selected")
                } else {
                    Text("Select an item")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.background)
            .font(.title)
        }
    }
}

//#Preview {
//    ConversationListDetail()
//}
