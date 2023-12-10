//
//  AssistantMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import SwiftUI

struct AssistantMessageView: View {
    var text: String
    
    var body: some View {
        MessageMarkdownView(text: text)
            .bubbleStyle(isMyMessage: false)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
            .padding(.leading, 15)
            .padding(.trailing, 95)
    }
}

#Preview {
    HStack {
        AssistantMessageView(text: """
                            dfffsdfsd
                            ```
                            This goes This goes This goes goes This goes
                            over multiple lines over multiple lines over multiple lines
                            ```
                            fafsdfsfs
                            """)
        Spacer()
    }
    .padding(.vertical)
}
