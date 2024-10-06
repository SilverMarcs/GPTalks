//
//  ConversationGroupView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct ConversationGroupView: View {
    var group: ConversationGroup
    
    @State var isHovered: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Group {
                switch group.role {
                case .user:
                    UserMessage(conversation: group.activeConversation)
                        .padding(.top, 5)
                case .assistant:
                    if group.activeConversation.toolCalls.isEmpty {
                        AssistantMessage(conversation: group.activeConversation)
                            .padding(.top, 5)
                    } else {
                        ToolCallView(conversation: group.activeConversation)
                            .padding(.top, 5)
                    }
                case .tool:
                    ToolMessage(conversation: group.activeConversation)
                        .padding(.vertical, 5)
                default:
                    Text("Unknown role")
                }
            }
            #if os(iOS)
            .opacity(0.9)
            #endif
            
            if group.session?.groups.firstIndex(where: { $0 == group }) == group.session?.resetMarker {
                ContextResetDivider() {
                    group.session?.resetMarker = nil
                }
                .padding(.vertical)
            }
        }
    }
}


#Preview {
    VStack {
        ConversationGroupView(group: .mockUserConversationGroup)
        ConversationGroupView(group: .mockAssistantConversationGroup)
    }
    .frame(width: 400)
    .padding()
}
