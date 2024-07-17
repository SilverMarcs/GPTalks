//
//  AssistantMessage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import MarkdownWebView

struct AssistantMessage: View {
    @ObservedObject var config = AppConfig.shared
    
    var conversation: Conversation
    @State var isHovered: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 14) {
                assistantImage
                VStack(alignment: .leading, spacing: 4) {
                    if let model = conversation.model {
                        Text(model.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if config.assistantMarkdown {
                        MarkdownWebView(conversation.content)
                    } else {
                        Text(conversation.content)
                    }
                    
                    if conversation.isReplying {
                        ProgressView()
                            .controlSize(.small)
                    }
                    #if os(macOS)
                    if let group = conversation.group, !conversation.isReplying {
                        ConversationMenu(group: group)
                            .opacity(isHovered ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isHovered)
                    }
                    #endif
                }
                .padding(.top, 2)
            }
        }
        .padding(.trailing, 30)
#if !os(macOS)
        .contextMenu {
            if let group = conversation.group, !conversation.isReplying {
                ConversationMenu(group: group)
            }
        }
#endif
        .onHover { isHovered in
            self.isHovered = isHovered
        }
    }
    
    var assistantImage: some View {
        Image(systemName: "sparkles")
            .resizable()
            .frame(width: 14, height: 14)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
                    .stroke(.tertiary, lineWidth: 1)
            )
    }
}

#Preview {
    let codeBlock = """
    This is a code block
    
    ```swift
    struct ContentView: View {
        var body: some View {
            Text("Hello, World!")
        }
    }
    ```
    
    Thank you for using me.
    
    """
    
    let conversation = Conversation(role: .user,
                                    content: codeBlock)
    conversation.isReplying = true
    
    return AssistantMessage(conversation: conversation)
        .frame(width: 500, height: 300)
}

