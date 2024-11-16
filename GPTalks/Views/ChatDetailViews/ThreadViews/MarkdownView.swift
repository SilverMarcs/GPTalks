//
//  MessageRowiew.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
import SwiftMarkdownView

struct MarkdownView: View {
    @Environment(ChatVM.self) private var chatVM
    
    @ObservedObject var config = AppConfig.shared
    var content: String

    var body: some View {
        SwiftMarkdownView(content)
            .markdownBaseURL("GPTalks Web Content")
//            .markdownHighlightString(chatVM.searchText)
            .markdownFontSize(CGFloat(config.fontSize))
            .renderSkeleton(config.renderSkeleton)
            .codeBlockTheme(config.codeBlockTheme)
//        Text(LocalizedStringKey(content)) // swiftui `native` markdown but its pretty bad
    }
}

#Preview {
    MarkdownView(content: Thread.mockAssistantThread.content)
        .frame(width: 600, height: 500)
        .padding()
}
