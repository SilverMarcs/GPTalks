//
//  MessageListView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI

struct MessageListView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var session: DialogueSession
    @State var isShowSettingsView = false
    @State var isShowDeleteWarning = false
    
    private let bottomID = "bottomID"
    
    var newList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(session.conversations) { conversation in
                        if conversation.role == "user" {
                            UserMessageView(conversation: conversation, session: session)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        if conversation.role == "assistant" {
                            AssistantMessageView(conversation: conversation, session: session)
                            .frame(maxWidth: .infinity, alignment: .leading)
                                .onChange(of: conversation.content) {
                                    scrollToBottom(proxy: proxy)
                                }
                        }

                        if session.conversations.firstIndex(of: conversation) == session.resetMarker {
                            ContextResetDivider(session: session)
                                .padding(.vertical)
                        }
                        
                        if session.errorDesc != "" {
                            ErrorDescView(session: session)
                                .padding()
                        }
                    }

                    Color.clear
                        .id(bottomID)
                }
                .padding(.vertical, 9)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomInputView(
                    session: session
                )
               #if os(iOS)
               .background(
                (colorScheme == .dark ? Color.black : Color.white)
                    .opacity(0.7)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
               )
               #else
              .background(.bar)
               #endif
            }
            .onChange(of: session.conversations.count) {
                scrollToBottom(proxy: proxy)
            }
            #if os(iOS)
            .onTapGesture {
                hideKeyboard()
            }
            #endif
        }
    }

    var body: some View {
        newList
            .background(.background)
            .alert("Delete all messages?", isPresented: $isShowDeleteWarning) {
                Button("Cancel", role: .cancel, action: {})
                Button("Confirm", role: .none, action: {
                    session.resetErrorDesc()
                    session.removeAllConversations()
                })
            }
            .navigationTitle($session.title)
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
                        Image(systemName: "square.text.square")
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
                
                ToolbarItemGroup {

                    Picker("Provider", selection: $session.configuration.provider) {
                        ForEach(Provider.allCases, id: \.self) { provider in
                            Text(provider.name)
                                .tag(provider.id)
                        }
                    }

                    Slider(value: $session.configuration.temperature, in: 0 ... 1, step: 0.1) {
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("1")
                    }
                    .frame(width: 130)

                    Picker("Model", selection: $session.configuration.model) {
                        ForEach(session.configuration.provider.models, id: \.self) { model in
                            Text(model.name)
                                .tag(model.id)
                        }
                    }
                    .frame(width: 125)

                    Picker("Context", selection: $session.configuration.contextLength) {
                        ForEach(Array(stride(from: 2, through: 20, by: 2)), id: \.self) { number in
                            Text("\(number) Messages")
                                .tag(number)
                        }
                    }

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
                            Image(systemName: "trash")
                        }
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

    private func scrollToBottom(proxy: ScrollViewProxy, anchor: UnitPoint = .bottom) {
        proxy.scrollTo(bottomID, anchor: anchor)
    }
}

#if canImport(UIKit)
extension View {
   func hideKeyboard() {
       UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
   }
}
#endif
