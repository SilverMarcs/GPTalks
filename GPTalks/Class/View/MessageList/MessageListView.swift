//
//  MessageListView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/3.
//

import SwiftUI

struct MessageListView: View {
    @ObservedObject var session: DialogueSession
    @FocusState var isTextFieldFocused: Bool
    @State var isShowSettingsView = false
    @State var isShowDeleteWarning = false

    var body: some View {
        contentView
            .background(.background)
            .alert("Delete all messages?", isPresented: $isShowDeleteWarning) {
                Button("Cancel", role: .cancel, action: {})
                Button("Confirm", role: .destructive, action: {
                    session.resetErrorDesc()
                    session.removeAllConversations()
                })
            }
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button {
                        isShowSettingsView = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(firstTwoWords(of: session.title))
                               .bold()
                               .foregroundColor(Color.primary)

                            Image(systemName:"chevron.right")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    .sheet(isPresented: $isShowSettingsView) {
                        DialogueSettingsView(configuration: $session.configuration, title: $session.title)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowDeleteWarning.toggle()
                    } label: {
                        Image(systemName:"trash")
                    }
                }
            }
#else
            .navigationTitle(session.title)
            .navigationSubtitle(session.configuration.model.name)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        isShowSettingsView = true
                    } label: {
                        Image(systemName:"slider.vertical.3")
                    }
                    .popover(isPresented: $isShowSettingsView) {
                        DialogueSettingsView(configuration: $session.configuration, title: $session.title)
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        isShowDeleteWarning.toggle()
                    } label: {
                        Image(systemName:"trash")
                    }
                }
            }
#endif
    }
    
    func firstTwoWords(of text: String) -> String {
        let words = text.split(separator: " ")
        let firstTwoWords = words.prefix(2)
        return firstTwoWords.joined(separator: " ")
    }

    @State var keyboadWillShow = false
    
    @Namespace var animation
    
    private let bottomID = "bottomID"
    
    var contentView: some View {
           ScrollViewReader { proxy in
               ScrollView {
                   VStack(spacing: 1) {
                       ForEach(Array(session.conversations.enumerated()), id: \.element.id) { index, conversation in
                           ConversationView(conversation: conversation, accentColor: session.configuration.provider.accentColor) { conversation in
                             Task { @MainActor in
                                 await session.regenerate(from: index)
                             }
                           } editHandler: { conversation in
                               Task { @MainActor in
                                   await session.edit(from: index, conversation: conversation)
                               }
                           } deleteHandler: {
                               withAnimation {
                                   session.removeConversation(conversation)
                               }
                               if session.conversations.isEmpty {
                                   session.resetErrorDesc()
                               }
                           }
                           .onAppear {
                               scrollToBottom(proxy: proxy)
                           }
                           .onChange(of: conversation.content) {
                               scrollToBottom(proxy: proxy)
                           }
                           .id(index)
                       }
                   }
                   .padding(.vertical, 5)
                   
                   if session.errorDesc != "" {
                       VStack(spacing: 15) {
                           Text(session.errorDesc)
                               .foregroundStyle(.red)
                           Button("Retry") {
                               Task { @MainActor in
                                   await session.retry()
                               }
                           }
                           .clipShape(.capsule(style: .circular))
                       }
                       .padding()
                   }
                   
                   Spacer()
                      .id(bottomID)
               }
               .onTapGesture {
                   isTextFieldFocused = false
               }
               .onAppear() {
                   scrollToBottom(proxy: proxy)
               }
               .onChange(of: session) {
                  scrollToBottom(proxy: proxy)
               }
               .safeAreaInset(edge: .bottom, spacing: 0) {
                   BottomInputView(
                      session: session,
                      isTextFieldFocused: _isTextFieldFocused
                   ) { _ in
                       Task { @MainActor in
                           await session.send()
                       }
                   } stop: {
                       session.stopStreaming()
                   } regen: {_ in
                       if session.isReplying() {
                           return
                       }
                       Task { @MainActor in
                           await session.regenerate(from: session.conversations.count - 1)
                       }
                   }
                   #if os(macOS)
                   .background(.bar)
                   #else
                   .background(.background)
                   #endif
               }
#if os(iOS)
                .onReceive(keyboardWillChangePublisher) { value in
                    if isTextFieldFocused && value {
                        self.keyboadWillShow = value
                    }
                }
                .onReceive(keyboardDidChangePublisher) { value in
                    if isTextFieldFocused {
                        if value {
                            withAnimation(.easeOut(duration: 0.05)) {
                                scrollToBottom(proxy: proxy)
                            }
                        } else {
                            self.keyboadWillShow = false
                        }
                    }
                }
#endif
           }
       }

    private func scrollToBottom(proxy: ScrollViewProxy, anchor: UnitPoint = .bottom) {
        proxy.scrollTo(bottomID, anchor: anchor)
    }
}

#if os(iOS)
extension MessageListView: KeyboardReadable {
    
}
#endif
