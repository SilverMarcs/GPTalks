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
        if sessionVM.selections.count == 1 {
            if let session = sessionVM.selections.first {
                ConversationList(session: sessionVM.selections.first!)
                    .id(session.id)
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
