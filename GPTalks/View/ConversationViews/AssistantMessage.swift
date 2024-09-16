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
    @Bindable var conversation: Conversation
    var providers: [Provider]
    
    @State private var isHovering: Bool = false
    @State private var showingTextSelection = false
    
    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            Image(conversation.group?.session?.config.provider.type.imageName ?? "brain.SFSymbol")
                .resizable()
                .frame(width: 17, height: 17)
                .foregroundStyle(Color(hex: conversation.group?.session?.config.provider.color ?? "#00947A").gradient)
            
            VStack(alignment: .leading, spacing: 7) {
                if let model = conversation.model {
                    Text(model.name)
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.secondary)
                        #if os(macOS)
                        .padding(.top, 2)
                        #endif
                }
                
                MarkdownView(conversation: conversation)
                
                if !conversation.dataFiles.isEmpty {
                    DataFileView(dataFiles: $conversation.dataFiles, isCrossable: false)
                }
                
                if conversation.isReplying {
                    ProgressView()
                        .controlSize(.small)
                }
                
                conversationMenuView
            }
        }
    #if !os(macOS)
    .contextMenu {
        if let group = conversation.group, !conversation.isReplying {
            ConversationMenu(group: group, providers: providers, isExpanded: .constant(true), toggleTextSelection: toggleTextSelection)
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
        self.isHovering = isHovered
    }
    #endif
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 30)
    }

    @ViewBuilder
    var conversationMenuView: some View {
        #if os(macOS) || targetEnvironment(macCatalyst)
        if let group = conversation.group, let session = group.session {
            ConversationMenu(group: group, providers: providers, isExpanded: .constant(true))
                .symbolEffect(.appear, isActive: !isHovering)
                .opacity(session.isReplying ? 0 : 1)
        }
        #endif
    }
    
    var spacing: CGFloat {
        #if os(macOS) || targetEnvironment(macCatalyst)
        10
        #else
        7
        #endif
    }
    
    func toggleTextSelection() {
        showingTextSelection.toggle()
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
    let providers: [Provider] = []
    let conversation = Conversation(role: .assistant,
                                    content: codeBlock)
    conversation.isReplying = true
    
    return AssistantMessage(conversation: conversation, providers: providers)
        .frame(width: 500, height: 300)
}

