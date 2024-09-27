//
//  EmptyConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/09/2024.
//

import SwiftUI

struct EmptyConversationList: View {
    @Bindable var session: Session
    var providers: [Provider]
    
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
        .toolbarBackground(.hidden, for: .windowToolbar)
    }
}

#Preview {
    let config = SessionConfig()
    let session = Session(config: config)
    let provider = Provider.factory(type: .openai)
    
    EmptyConversationList(session: session, providers: [provider])
}
