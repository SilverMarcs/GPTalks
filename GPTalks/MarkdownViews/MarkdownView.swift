//
//  MessageRowiew.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/3/24.
//

import SwiftUI
import MarkdownWebView

struct MarkdownView: View {
    @ObservedObject var config = AppConfig.shared
    var content: String
    
    var body: some View {
        switch config.markdownProvider {
            case .webview:
                MarkdownWebView(content)
            case .native:
                Text(LocalizedStringKey(content))
            case .disabled:
                Text(content)
        }
    }
}
