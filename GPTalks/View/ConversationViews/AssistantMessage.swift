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
    @State var showingTextSelection = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: spacing) {
                AssistantImage(size: size)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let model = conversation.model {
                        Text(model.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if config.assistantMarkdown {
                        MarkdownWebView(conversation.content)
                    } else {
                        Text(LocalizedStringKey(conversation.content))
                            .textSelection(.enabled)
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
#if !os(macOS)
        .contextMenu {
            if let group = conversation.group, !conversation.isReplying {
                ConversationMenu(group: group, toggleTextSelection: toggleTextSelection)
            }
        } preview: {
            Text("Assistant Message")
                .padding()
        }
        .sheet(isPresented: $showingTextSelection) {
            TextSelectionView(content: conversation.content)
        }
#else
        .onHover { isHovered in
            self.isHovered = isHovered
        }
#endif
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 30)
    }
    
    func toggleTextSelection() {
        showingTextSelection.toggle()
    }
    
    var spacing: CGFloat {
        #if os(macOS)
        10
        #else
        7
        #endif
    }
    
    var size: CGFloat {
        #if os(macOS)
        12
        #else
        10
        #endif
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

