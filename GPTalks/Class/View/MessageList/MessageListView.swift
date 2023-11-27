//
//  MessageListView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/3.
//

import SwiftUI

struct MessageListView: View {
    @Environment (\.colorScheme) var colorScheme
    
    @ObservedObject var session: DialogueSession
    @FocusState var isTextFieldFocused: Bool
    @State var isShowSettingsView = false
    @State var isShowDeleteWarning = false
    @State var title = ""

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
            .onChange(of: title, perform: { value in
                session.title = value
            })
            .onAppear {
                title = session.title
            }
            .navigationTitle($title)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowSettingsView) {
                DialogueSettingsView(configuration: $session.configuration, title: session.title)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            isShowSettingsView.toggle()
                        } label: {
                            Text("Chat Settings")
                            Image(systemName: "slider.vertical.3")
                        }
                        
                        Button(role: .destructive) {
                            isShowDeleteWarning.toggle()
                        } label: {
                            Text("Delete All Messages")
                            Image(systemName: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
#else
            .navigationSubtitle(session.configuration.model.name)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        isShowSettingsView = true
                    } label: {
                        Image(systemName:"slider.vertical.3")
                    }
                    .popover(isPresented: $isShowSettingsView) {
                        DialogueSettingsView(configuration: $session.configuration, title: session.title)
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        isShowDeleteWarning.toggle()
                    } label: {
                        Image(systemName:"trash")
                    }
                    .keyboardShortcut(.delete, modifiers: [.command])
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
                               session.removeConversation(conversation)
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
                   #if os(iOS)
                   .background(
                        Color.black
                            .opacity(0.9)
                            .background(.ultraThinMaterial)
                            .ignoresSafeArea()
                   )
                   #else
                  .background(.bar)
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
