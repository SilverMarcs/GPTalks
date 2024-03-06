//
//  ToolMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/03/2024.
//

import SwiftUI

struct ToolMessageView: View {
    var conversation: Conversation
    var session: DialogueSession
    
    @State var showPopover = false
    
    var body: some View {
        
        Button{
            showPopover.toggle()
        } label: {
            HStack {
                Text(conversation.role)
            }
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showPopover, arrowEdge: .leading) {
            ScrollView {
                Text(conversation.content)
                    .padding()
            }
            .frame(width: 300, height: 200)
        }
    }
}
