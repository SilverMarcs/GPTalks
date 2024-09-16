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
    
    @State var isHovered: Bool = false
    @State var showingTextSelection = false
    @State var showArguments = false

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            Image(conversation.group?.session?.config.provider.type.imageName ?? "brain.SFSymbol")
                .resizable()
                .frame(width: size, height: size)
                .foregroundStyle(Color(hex: conversation.group?.session?.config.provider.color ?? "#00947A"))
            
            VStack(alignment: .leading, spacing: 7) {
                if !conversation.toolCalls.isEmpty {
                    toolCallsView
                        .padding(.top, 1)
                } else {
                    modelNameView
                        .padding(.top, 2)
                }
                
                if showArguments {
                    tool
                }
                
                if conversation.toolCalls.isEmpty {
                    MarkdownView(conversation: conversation)
                } else {
                    EmptyView()
                }
                
                if !conversation.dataFiles.isEmpty {
                    DataFileView(dataFiles: $conversation.dataFiles, isCrossable: false)
                } else {
                    EmptyView()
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
            self.isHovered = isHovered
        }
#endif
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 30)
    }
    
    var tool: some View {
        ForEach(Array(conversation.toolCalls.enumerated()), id: \.element.id) { index, toolCall in
            VStack(alignment: .leading) {
                Text("Tool: \(toolCall.tool.displayName)")
                    .font(.headline)
                Text("Arguments: \(toolCall.arguments)")
                    .padding(.leading)
                    .textSelection(.enabled)
            }
        }
    }
    
    var toolCallsView: some View {
        Button {
            showArguments.toggle()
        } label: {
            HStack {
                Text("^[Called \(conversation.toolCalls.count) Tool](inflect: true)")
                    .foregroundStyle(.secondary)
                
                if conversation.isReplying {
                    ProgressView()
                        .controlSize(.mini)
                } else {
                    Image(systemName: showArguments ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    var modelNameView: some View {
        if let model = conversation.model {
            Text(model.name)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    var conversationMenuView: some View {
        #if os(macOS) || targetEnvironment(macCatalyst)
        if let group = conversation.group, let session = group.session {
            ConversationMenu(group: group, providers: providers, isExpanded: .constant(true))
                .symbolEffect(.appear, isActive: !isHovered)
                .opacity(session.isReplying ? 0 : 1)
        }
        #endif
    }
    
    func toggleTextSelection() {
        showingTextSelection.toggle()
    }
    
    var spacing: CGFloat {
        #if os(macOS) || targetEnvironment(macCatalyst)
        10
        #else
        7
        #endif
    }
    
    var size: CGFloat {
        #if os(macOS) || targetEnvironment(macCatalyst)
        17
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
    let providers: [Provider] = []
    let conversation = Conversation(role: .user,
                                    content: codeBlock)
    conversation.isReplying = true
    
    return AssistantMessage(conversation: conversation, providers: providers)
        .frame(width: 500, height: 300)
}

