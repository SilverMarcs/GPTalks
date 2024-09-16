////
////  ToolMessage.swift
////  GPTalks
////
////  Created by Zabir Raihan on 15/09/2024.
////
//
//import SwiftUI
//
//struct ToolMessage: View {
//    var conversation: Conversation
//    var providers: [Provider] = []
//    @State private var showPopover = false
//    @State var isHovered: Bool = false
//    
//    var body: some View {
//        if let toolResponse = conversation.toolResponse {
//            HStack(alignment: .top, spacing: spacing) {
//                Image(systemName: "hammer")
//                    .resizable()
//                    .frame(width: size, height: size)
//                    .foregroundStyle(.teal)
//                
//                VStack(alignment: .leading, spacing: 7) {
//                    Text("Tool")
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                    
//                    button
//                        .popover(isPresented: $showPopover, arrowEdge: .leading) {
//                            ScrollView {
//                                Text(toolResponse.processedContent)
//                                    .textSelection(.enabled)
//                                    .padding()
//                            }
//                            .frame(width: 500, height: 400)
//                        }
//                    
//                    #if os(macOS) || targetEnvironment(macCatalyst)
//                    if conversation.toolCalls.isEmpty, let group = conversation.group, let session = group.session {
//                        ConversationMenu(group: group, providers: providers, isExpanded: .constant(true))
//                            .symbolEffect(.appear, isActive: !isHovered)
//                            .opacity(session.isReplying ? 0 : 1)
//                    }
//                    #endif
//                }
//                .padding(.top, 2)
//                
//                Spacer()
//            }
//            .onHover { isHovered in
//                self.isHovered = isHovered
//            }
//        }
//    }
//    
//    var button: some View {
//        Button {
//            showPopover.toggle()
//        } label: {
//            HStack(spacing: 4) {
//                if let toolResponse = conversation.toolResponse {
//                    Text("Used")
//                        .foregroundStyle(.secondary)
//
//                    Text(toolResponse.tool.displayName)
//                        .fontWeight(.semibold)
//
//                    if conversation.isReplying {
//                        ProgressView()
//                            .controlSize(.small)
//                    } else {
//                        Image(systemName: toolResponse.tool.icon)
//                    }
//                }
//            }
//            .bubbleStyle()
//        }
//        .buttonStyle(.plain)
//    }
//    
//    var size: CGFloat {
//        #if os(macOS) || targetEnvironment(macCatalyst)
//        17
//        #else
//        10
//        #endif
//    }
//    
//    var spacing: CGFloat {
//        #if os(macOS) || targetEnvironment(macCatalyst)
//        10
//        #else
//        7
//        #endif
//    }
//}
//
////#Preview {
////    ToolMessage()
////}
