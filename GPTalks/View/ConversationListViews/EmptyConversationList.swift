//
//  EmptyConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/09/2024.
//

import SwiftUI

struct EmptyConversationList: View {
    @Bindable var session: ChatSession
    
    var body: some View {
        Image(session.config.provider.type.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundStyle(.quaternary)
            .fullScreenBackground()
    }
}

#Preview {
    EmptyConversationList(session: .mockChatSession)
}
