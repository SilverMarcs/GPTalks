//
//  MessageListView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI

struct MessageListView: View {
    @Environment (\.colorScheme) var colorScheme
    
    @ObservedObject var session: DialogueSession
    @FocusState var isTextFieldFocused: Bool
    @State var isShowSettingsView = false
    @State var isShowDeleteWarning = false
    @State var title = ""
    
//    let saveConversation: (SavedConversation) -> Void
    private let bottomID = "bottomID"
    
    var newList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(session.conversations) { conversation in
                        if conversation.role == "user" {
                            UserMessageView(text: conversation.content)
                        } else if conversation.role == "assistant" {
                            MessageMarkdownView(text: conversation.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                                .bubbleStyle(isMyMessage: false)
                                .padding(.leading, 15)
                                .padding(.trailing, 95)
                                .onChange(of: conversation.content) {
                                    scrollToBottom(proxy: proxy)
                                }
                        } else {
                            ReplyingIndicatorView()
                        }
                    }
                    
                    Spacer()
                       .id(bottomID)
                }
            }

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
             (colorScheme == .dark ? Color.black : Color.white)
                 .opacity(colorScheme == .dark ? 0.9 : 0.6)
                     .background(.ultraThinMaterial)
                     .ignoresSafeArea()
            )
            #else
           .background(.bar)
            #endif
        }
    }

    var body: some View {
//        contentView
        newList
            .background(.background)
            .alert("Delete all messages?", isPresented: $isShowDeleteWarning) {
                Button("Cancel", role: .cancel, action: {})
                Button("Confirm", role: .none, action: {
                    session.resetErrorDesc()
                    session.removeAllConversations()
                })
            }
            .onChange(of: title) {
               session.title = title
            }
            .onAppear {
                title = session.title
            }
            .navigationTitle($title)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowSettingsView) {
                DialogueSettingsView(configuration: $session.configuration, provider: session.configuration.provider)
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
                        
                        Button {
                            session.resetContext()
                        } label: {
                            Text("Reset Context")
                            Image(systemName: "eraser")
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
                        VStack {
                            Text("System Prompt")
                            TextEditor(text: $session.configuration.systemPrompt)
                                .font(.body)
                                .frame(width: 200, height: 70)
                                .scrollContentBackground(.hidden)
                        }
                        .padding(10)
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Picker("Provider", selection: $session.configuration.provider) {
                        ForEach(Provider.allCases, id: \.self) { provider in
                            Text(provider.name)
                                .tag(provider.id)
                        }
                    }
                    .onChange(of: session.configuration.provider) {
                        session.configuration.model = session.configuration.provider.preferredModel
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
//                    HStack(spacing: 10) {
                        Slider(value: $session.configuration.temperature, in: 0 ... 1, step: 0.1) {
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("1")
                        }
                        .frame(width: 130)
//                        Text(String(format: "%.2f", session.configuration.temperature))
//                            .frame(width: 30)
//                    }
//                    .frame(width: 200)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Picker("Model", selection: $session.configuration.model) {
                        ForEach(session.configuration.provider.models, id: \.self) { model in
                            Text(model.name)
                                .tag(model.id)
                        }
                    }
                    .frame(width: 125)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Picker("Context", selection: $session.configuration.contextLength) {
                        ForEach(Array(stride(from: 2, through: 20, by: 2)), id: \.self) { number in
                            Text("\(number) Messages")
                                .tag(number)
                        }
                    }
                }
                
                

                
//                ToolbarItem(placement: .cancellationAction) {
//                    Button {
//                        session.resetContext()
//                    } label: {
////                        Text("Reset Context")
//                        Image(systemName: "eraser")
//                    }
//                    .keyboardShortcut(.delete, modifiers: [.command])
//                }
                
//                ToolbarItem(placement: .cancellationAction) {
//                    Button(role: .destructive) {
//                        isShowDeleteWarning.toggle()
//                    } label: {
////                        Text("Delete All Messages")
//                        Image(systemName:"trash")
//                    }
//                }
//                
                ToolbarItem(placement: .cancellationAction) {
                    Menu {
                        Button {
                            session.resetContext()
                        } label: {
                            Text("Reset Context")
                            Image(systemName: "eraser")
                        }
                        .keyboardShortcut(.delete, modifiers: [.command])

                        Button(role: .destructive) {
                            isShowDeleteWarning.toggle()
                        } label: {
                            Text("Delete All Messages")
                            Image(systemName:"trash")
                        }
//                        .opacity(0)
                    } label: {
                        Image(systemName: "ellipsis.circle")
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
    
//    @Namespace var animation
    
//    private let bottomID = "bottomID"
    
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
                           } saveHandler: {
//                               saveConversation(conversation.toSavedConversation())
                           }
                           .onChange(of: conversation.content) {
                               scrollToBottom(proxy: proxy)
                           }
                           .id(index)
                           
                           if session.conversations.firstIndex(of: conversation) == session.resetMarker {
                               ContextResetDivider()
                                   .padding(.vertical)
                                   .onAppear {
                                       #if os(iOS)
                                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                           withAnimation {
                                               scrollToBottom(proxy: proxy)
                                           }
                                       }
                                       #else
                                       scrollToBottom(proxy: proxy)
                                       #endif
                                   }
                           }
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
                   
//                   Spacer()
//                      .id(bottomID)
               }
               .onAppear {
                   #if os(iOS)
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                       withAnimation {
                           scrollToBottom(proxy: proxy)
                       }
                   }
                   #else
                   scrollToBottom(proxy: proxy)
                   #endif
               }
               .onChange(of: session.conversations.count) {
                   scrollToBottom(proxy: proxy)
               }
               .onTapGesture {
                   isTextFieldFocused = false
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
                    (colorScheme == .dark ? Color.black : Color.white)
                        .opacity(colorScheme == .dark ? 0.9 : 0.6)
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
