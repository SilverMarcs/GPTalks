//
//  MessageListView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/3.
//

import SwiftUI
import SwiftUIX
//import Introspect

struct MessageListView: View {
    @ObservedObject var session: DialogueSession
    @FocusState var isTextFieldFocused: Bool
    
    @State var isShowSettingsView = false
    
    @State var isShowClearMessagesAlert = false
    
    @State var isShowLoadingToast = false
    
    var body: some View {
        contentView
            .alert(
                "Warning",
                isPresented: $isShowClearMessagesAlert
            ) {
                Button(role: .destructive) {
                    session.clearMessages()
                } label: {
                    Text("Confirm")
                }
            } message: {
                Text("Remove all messages?")
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
                               .foregroundColor(.label)

                            Image(systemName:"chevron.right")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    .sheet(isPresented: $isShowSettingsView) {
                        dialogSettings
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
                   VStack(spacing: 0) {
                       ForEach(enumerating: Array(session.conversations.enumerated())) { index, conversation in
                           ConversationView(conversation: conversation, service: session.configuration.service) { conversation in
                             Task { @MainActor in
                                 await session.regenerate(from: index, scroll: {
                                     scrollToBottom(proxy: proxy, anchor: $0)
                                 })
                             }
                           } editHandler: { conversation in
                               Task { @MainActor in
                                   await session.edit(from: index, conversation: conversation, scroll: {
                                       scrollToBottom(proxy: proxy, anchor: $0)
                                   })
                               }
                           } deleteHandler: {
                               session.removeConversation(at: index)
                           }
                           .id(index)
                       }
                   }
                   .padding(.vertical, 5)
                   
                   if session.errorDesc != "" {
                       VStack(spacing: 15) {
                           Text(session.errorDesc)
                               .foregroundStyle(.red)
                           Button {
                               Task { @MainActor in
                                   await session.retry() {
                                       scrollToBottom(proxy: proxy, anchor: $0)
                                   }
                               }
                                   
                           } label: {
                                 Text("Retry")
                            }
                       }
                       .padding()
                   }
                   
                   Spacer()
                      .id(bottomID)
               }
               .onTapGesture {
                   isTextFieldFocused = false
               }
               .safeAreaInset(edge: .bottom, spacing: 0) {
                   BottomInputView(
                      session: session,
                      isLoading: $isShowLoadingToast,
                      namespace: animation,
                      isTextFieldFocused: _isTextFieldFocused
                   ) { _ in
                      sendMessage(proxy)
                   } stop: {
                       session.stopStreaming()
                   }
               }
               .onAppear() {
                   scrollToBottom(proxy: proxy)
               }
               .onChange(of: session) {
                  scrollToBottom(proxy: proxy)
               }
#if os(iOS)
                .onReceive(keyboardWillChangePublisher) { value in
                    if isTextFieldFocused && value {
                        self.keyboadWillShow = value
                    }
                }.onReceive(keyboardDidChangePublisher) { value in
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

#if os(iOS)
    var dialogSettings: some View {
        NavigationStack {
            DialogueSettingsView(configuration: $session.configuration, title: $session.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button {
                            isShowSettingsView = false
                        } label: {
                            Text("Done")
                                .bold()
                        }
                    }
                }
        }
    }
#endif
    
    func sendMessage(_ proxy: ScrollViewProxy) {
        if !session.conversations.isEmpty && session.lastConversation.isReplying {
            return
        }
        Task { @MainActor in
            await session.send()
            {
                scrollToBottom(proxy: proxy, anchor: $0)
            }
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
