//
//  MessageRowiew.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
import SwiftMarkdownView

struct MarkdownView: View {
    @Environment(ChatVM.self) private var sessionVM
    
    @ObservedObject var config = AppConfig.shared
    var content: String

    var body: some View {
        SwiftMarkdownView(content)
            .markdownBaseURL("GPTalks Web Content")
            .markdownHighlightString(sessionVM.searchText)
            .markdownFontSize(CGFloat(config.fontSize))
    }
}



#Preview {
    MarkdownView(content: Thread.mockAssistantThread.content)
        .frame(width: 600, height: 500)
        .padding()
}
