//
//  ConversationView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/3.
//

import SwiftUI
import SwiftUIX
import Kingfisher

struct AnimationID {
    
    static let senderBubble = "SenderBubble"
    
}

struct ConversationView: View {
        
    let conversation: Conversation

//    let namespace: Namespace.ID
//    var lastConversationDate: Date?
    let retryHandler: (Conversation) -> Void
    var editHandler: (Conversation) -> Void?
    
    @State var isEditing = false
    @FocusState var isFocused: Bool
    @State var editingMessage: String = ""
    var deleteHandler: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            if conversation.role == "user" {
                userMessage
                    .padding(.leading, horizontalPadding(for: .text))
                    .padding(.vertical, 5)
            } else if conversation.role == "assistant" {
                assistantMessage
                    .transition(.move(edge: .leading))
                    .padding(.trailing, horizontalPadding(for: .text))
                    .padding(.vertical, 5)
            } else {
                ReplyingIndicatorView()
                
            }
        }
        .transition(.moveAndFade)
        .padding(.horizontal, 15)
        
        .contextMenu {
            if conversation.role == "assistant" {
                Button {
                    retryHandler(conversation)
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry")
                    }
                }
            }
            if conversation.role == "user" {
                Button {
                    editingMessage = conversation.content
                    isEditing = true
                    isFocused = isEditing
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                }
            }
            Button {
                conversation.content.copyToPasteboard()
            } label: {
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Copy")
                }
            }
            Button(role: .destructive) {
                deleteHandler?()
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
        }
    }
    
    private func horizontalPadding(for type: MessageType) -> CGFloat {
#if os(iOS)
        return 55
#else
        return 105
#endif
    }
    
    var userMessage: some View {
        HStack(spacing: 0) {
            Spacer()
            if isEditing {
                editControls()
                TextField("Your edited text here", text: $editingMessage, axis: .vertical)
                    .focused($isFocused)
                    .textFieldStyle(.plain)
                    .bubbleStyle(isMyMessage: true, type: .textEdit)
            } else {
                Text(conversation.content)
                    .textSelection(.enabled)
                    .bubbleStyle(isMyMessage: true, type: .text)
            }
        }
    }
    
    var assistantMessage: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                if AppConfiguration.shared.isMarkdownEnabled{
                    MessageMarkdownView(text: conversation.content)
                        .textSelection(.enabled)
                }
                
                if conversation.isReplying {
                    ReplyingIndicatorView()
                        .frame(width: 48, height: 24)
                }
            }
            .bubbleStyle(isMyMessage: false, type: .text)
            
            Spacer()
        }
    }
    
    
    @ViewBuilder
    func editControls() -> some View {
        HStack(spacing: 15) {
            Button {
                isEditing = false
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.borderless)
            .foregroundColor(.red)

            Button {
                editHandler(Conversation(role: "user", content: editingMessage))
                isEditing = false
                isFocused = isEditing
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.borderless)
            .foregroundColor(.green)
            .keyboardShortcut(isEditing ? .defaultAction : .none)

        }
        .padding(.trailing, 10)
    }
    

//    var senderMessage: some View {
    //        HStack(spacing: 0) {
    //            Spacer()
    //            if conversation.isLast {
    //                messageEditButton() // TODO put it eveyrwhere when focused but remember to delete all messages below it
    //                senderMessageContent
    //                    .frame(minHeight: 24)
    //                    .bubbleStyle(isMyMessage: true, type: isEditing ? .textEdit : conversation.inputType)
    //                    .matchedGeometryEffect(id: AnimationID.senderBubble, in: namespace)
    //            } else {
    //                senderMessageContent
    //                    .frame(minHeight: 24)
    //                    .bubbleStyle(isMyMessage: true, type: conversation.inputType)
    //            }
    //        }
//    }

    
//    @ViewBuilder
//    var senderMessageContent: some View {
//        if isEditing {
//            TextField("", text: $editingMessage, axis: .vertical)
//                .foregroundColor(.primary)
//                .focused($isFocused)
//                .lineLimit(1...20)
//                .background(Color(.darkGray))x
//                .textFieldStyle(.plain)
//        } else {
//            Text(conversation.input)
//                .textSelection(.enabled)
//        }
//    
//    }
 
//    @ViewBuilder
//    func messageEditButton() -> some View {
//        if conversation.isReplying {
//            EmptyView()
//        } else {
//            Button {
//                if isEditing {
//                    if editingMessage != conversation.input {
//                        var message = conversation
//                        message.input = editingMessage
//                        retryHandler(message)
//                    }
//                } else {
//                    editingMessage = conversation.input
//                }
//                isEditing.toggle()
//                isFocused = isEditing
//            } label: {
//                if isEditing {
//                    Image(systemName: "checkmark")
//                } else {
//                    Image(systemName: "pencil")
//                }
//            }
//#if os(macOS)
//            .buttonStyle(.borderless)
//            .foregroundColor(.accentColor)
//#endif
//            .keyboardShortcut(isEditing ? .defaultAction : .none)
//            .frame(width: 30)
//            .padding(.trailing)
//            .padding(.leading, -50)
//        }
//    }
    
    
//    var replyMessage: some View {
//        HStack(spacing: 0) {
//            VStack(alignment: .leading) {
//                switch conversation.replyType {
//                case .text, .textEdit:
//                    TextMessageView(text: conversation.reply ?? "", isReplying: conversation.isReplying)
//                case .error:
//                    ErrorMessageView(error: conversation.errorDesc) {
//                        retryHandler(conversation)
//                    }
//                }
//                if conversation.isReplying {
//                    ReplyingIndicatorView()
//                        .frame(width: 48, height: 24)
//                }
//            }
//            .frame(minHeight: 24)
//            .bubbleStyle(isMyMessage: false, type: conversation.replyType)
//            retryButton
//            Spacer()
//        }
//
//    }
    
//    @ViewBuilder
//    var retryButton: some View {
//        if !conversation.isReplying {
//            if conversation.errorDesc == nil && conversation.isLast {
//                Button {
//                    retryHandler(conversation)
//                } label: {
//                    HStack {
//                        Image(systemName: "arrow.clockwise")
//                    }
//                }
//#if os(macOS)
//                .buttonStyle(.borderless)
//                .foregroundColor(.accentColor)
//#endif
//                .frame(width: 30)
//                .padding(.leading)
//                .padding(.trailing, -50)
//            }
//        }
//    }
    
}


//struct MessageRowView_Previews: PreviewProvider {
//    
//    static let message = Conversation(
//        isReplying: true, isLast: false,
//        input: "What is SwiftUI?",
//        reply: "SwiftUI is a user interface framework that allows developers to design and develop user interfaces for iOS, macOS, watchOS, and tvOS applications using Swift, a programming language developed by Apple Inc.")
//    
//    static let message2 = Conversation(
//        isReplying: false, isLast: false,
//        input: "What is SwiftUI?",
//        reply: "",
//        errorDesc: "ChatGPT is currently not available")
//    
//    static let message3 = Conversation(
//        isReplying: true, isLast: false,
//        input: "What is SwiftUI?",
//        reply: "")
//    
//    static let message4 = Conversation(
//        isReplying: false, isLast: true,
//        input: "What is SwiftUI?",
//        reply: "SwiftUI is a user interface framework that allows developers to design and develop user interfaces for iOS, macOS, watchOS, and tvOS applications using Swift, a programming language developed by Apple Inc.",
//        errorDesc: nil)
//    
//    @Namespace static  var animation
//    
//    static var previews: some View {
//        NavigationStack {
//            ScrollView {
//                ConversationView(conversation: message, namespace: animation,  retryHandler: { message in
//                    
//                })
//                ConversationView(conversation: message2, namespace: animation,  retryHandler: { message in
//                    
//                })
//                ConversationView(conversation: message3, namespace: animation,  retryHandler: { message in
//                    
//                })
//                ConversationView(conversation: message4, namespace: animation,  retryHandler: { message in
//                    
//                })
//            }
//            .frame(width: 400)
//            .previewLayout(.sizeThatFits)
//        }
//    }
//}
