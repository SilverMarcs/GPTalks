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
        ScrollView {
            ZStack {
                // Reserve space matching the scroll view's frame
                Spacer().containerRelativeFrame([.horizontal, .vertical])

                VStack {
                    Image(session.config.provider.type.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.quaternary)
                }
            }
        }
//        .scrollBounceBehavior(.basedOnSize) // disables bounce if the content fits
        .scrollContentBackground(.visible)
        .background(.background)
    }
}

#Preview {
    EmptyConversationList(session: .mockChatSession)
}
