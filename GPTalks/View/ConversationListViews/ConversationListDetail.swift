//
//  ConversationListExt.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct ConversationListDetail: View {
    @Environment(SessionVM.self) private var sessionVM
    
    var body: some View {
        if sessionVM.state == .images {
            if sessionVM.imageSelections.count == 1 {
                if let imageSession = sessionVM.imageSelections.first {
                    ImageGenerationList(session: imageSession)
                        .id(imageSession.id)
                }
            }
        } else if sessionVM.state == .chats {
            if sessionVM.selections.count == 1 {
                if let chatSession = sessionVM.selections.first {
                    ConversationList(session: sessionVM.selections.first!)
                        .id(chatSession.id)
                }
            }
        } else {
            Text("Select an item")
                .font(.title)
        }
    }
}

#Preview {
    ConversationListDetail()
}
