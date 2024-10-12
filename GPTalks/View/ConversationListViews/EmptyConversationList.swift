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
        VStack(alignment: .center) {
            Image(session.config.provider.type.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.quaternary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
        #if os(macOS)
        .toolbarBackground(.hidden, for: .windowToolbar)
        #endif
    }
}

#Preview {
    EmptyConversationList(session: .mockChatSession)
}
