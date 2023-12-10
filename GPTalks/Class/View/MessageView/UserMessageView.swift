//
//  UserMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import SwiftUI

struct UserMessageView: View {
    var text: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .textSelection(.enabled)
                .bubbleStyle(isMyMessage: true, accentColor: .accentColor)
                .padding(.trailing, 15)
                .padding(.leading, 95)
        }
    }
}

#Preview {
    HStack {
        Spacer()
        UserMessageView(text: """
                            This goes This goes This goes goes This goes
                            over multiple lines over multiple lines over multiple lines
                            """)
    }
    .padding(.vertical)
}
