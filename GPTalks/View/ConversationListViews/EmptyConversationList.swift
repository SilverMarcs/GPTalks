//
//  EmptyThreadList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/09/2024.
//

import SwiftUI

struct EmptyThreadList: View {
    @Bindable var session: Chat
    
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
    EmptyThreadList(session: .mockChat)
}
