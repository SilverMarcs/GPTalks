//
//  MacOSMessages.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
struct MacOSMessages: View {
    @Environment(DialogueViewModel.self) private var viewModel

    @Bindable var session: DialogueSession

    @State private var isUserScrolling = false
    @State var isShowSysPrompt: Bool = false
    @FocusState var isTextFieldFocused: Bool

    var body: some View {
        ScrollViewReader { proxy in
            normalList
            .navigationTitle(session.title)
            .navigationSubtitle(session.configuration.systemPrompt.truncated(to: 40))
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomInputView(
                    session: session,
                    focused: _isTextFieldFocused
                )
                .background(.bar)
            }
            .onChange(of: viewModel.selectedDialogue) {
                isTextFieldFocused = true
                
                if viewModel.selectedState == .images {
                    viewModel.selectedState = .recent
                }
                
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
                    if event.modifierFlags.contains(.command) && event.characters == "v" {
                        session.pasteImageFromClipboard()
                    }
                    return event
                }
                
                if AppConfiguration.shared.alternateMarkdown {
                    scrollToBottom(proxy: proxy, animated: true, delay: 0.2)
                    scrollToBottom(proxy: proxy, animated: true, delay: 0.4)
                    scrollToBottom(proxy: proxy, animated: true, delay: 0.8)
                } else {
                    scrollToBottom(proxy: proxy, animated: false)
                }
            }
            .onChange(of: session.conversations.last?.content) {
                if !isUserScrolling {
                    scrollToBottom(proxy: proxy, animated: true)
                }
            }
            .onChange(of: session.conversations.last?.isReplying) {
                if !session.isReplying() {
                    isUserScrolling = false
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
                if session.isReplying() {
                    isUserScrolling = true
                }
            }
            .onChange(of: session.isAddingConversation) {
                scrollToBottom(proxy: proxy, animated: false)
            }
            .onChange(of: session.input) {
                if session.input.contains("\n") || (session.input.count > 105) {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.resetMarker) {
                if session.resetMarker == session.conversations.count - 1 {
                    scrollToBottom(proxy: proxy)
                }
                isTextFieldFocused = true
                
                if session.containsConversationWithImage {
                    session.configuration.model = session.configuration.provider.visionModels[0]
                }
            }
            .onChange(of: session.errorDesc) {
                scrollToBottom(proxy: proxy, animated: true)
            }
            .onChange(of: session.inputImages) {
                if !session.inputImages.isEmpty {
                    if !session.configuration.provider.visionModels.contains(session.configuration.model) {
                        session.configuration.model = session.configuration.provider.visionModels[0]
                    }
                    scrollToBottom(proxy: proxy, animated: true)
                }
            }
            .onChange(of: session.configuration.provider) {
                if session.containsConversationWithImage {
                    session.configuration.model = session.configuration.provider.visionModels[0]
                } else {
                    session.configuration.model = session.configuration.provider.preferredChatModel
                }
            }
            .onDrop(of: [UTType.image.identifier], isTargeted: nil) { providers -> Bool in
                if let itemProvider = providers.first {
                    itemProvider.loadObject(ofClass: NSImage.self) { (image, error) in
                        DispatchQueue.main.async {
                            if let image = image as? NSImage {
                                session.inputImages.append(image)
                            } else {
                                print("Could not load image: \(String(describing: error))")
                            }
                        }
                    }
                    return true
                }
                return false
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Menu {
                        Section {
                            Button("Generate Title") {
                                Task { await session.generateTitle(forced: true) }
                            }
                            
                            Button("System Prompt") {
                                isShowSysPrompt = true
                            }
                        }
                        
                        Section {
                            Button("Regenerate") {
                                Task { await session.regenerateLastMessage() }
                            }

                            Button("Reset Context") {
                                session.resetContext()
                            }
                        }

                        Button("Delete All Messages") {
                            session.removeAllConversations()
                        }
                    } label: {
                        Image(systemName: "slider.vertical.3")
                    }
                    .menuIndicator(.hidden)
                    
                    Button {
                        isShowSysPrompt = true
                    } label: {
                        Image(systemName: "square.text.square")
                    }
                }

                ToolbarItemGroup {
                        
                    ProviderPicker(session: session)

                    TempSlider(session: session)
                        .frame(width: 130)

                    ModelPicker(session: session)
                        .frame(width: 90)
                }
            }
            .sheet(isPresented: $isShowSysPrompt) {
                VStack {
                    HStack {
                        Button("Hidden") {
                            
                        }
                        .opacity(0)
                        
                        Spacer()
                        
                        Text("System Prompt")
                            .bold()
                        
                        Spacer()
                        
                        Button("Done") {
                            isShowSysPrompt = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Divider()
                    
                    TextEditor(text: $session.configuration.systemPrompt)
                        .font(.body)
                        .frame(width: 300, height: 150)
                        .scrollContentBackground(.hidden)
                }
                .padding(10)
            }
        }
    }

    private var normalList: some View {
        Group {
            if AppConfiguration.shared.alternateChatUi {
                List {
                    LazyVStack {
                        ForEach(session.conversations) { conversation in
                            ConversationView(session: session, conversation: conversation)
                                .id(conversation.id)
                        }
                        
                        ErrorDescView(session: session)
                        
                        Color.clear
                            .listRowSeparator(.hidden)
                            .frame(height: 20)
                    }
                    .padding(.horizontal, -8)
                    .id("bottomID")
                }
                .listStyle(.plain)
                
            } else {
                List {
                    VStack {
                        ForEach(session.conversations) { conversation in
                            ConversationView(session: session, conversation: conversation)
                        }
                        
                        ErrorDescView(session: session)
                    }
                    .id("bottomID")
                }
            }
        }
    }
    
    private var alternateList: some View {
        // not used for now
        List {
            ForEach(Array(session.conversations.chunked(fromEndInto: 10).enumerated()), id: \.offset) { _, chunk in
                VStack {
                    ForEach(chunk, id: \.self) { conversation in
                        ConversationView(session: session, conversation: conversation)
                    }
                }
                .listRowSeparator(.hidden)
            }

            ErrorDescView(session: session)
                .listRowSeparator(.hidden)

            Spacer()
                .listRowSeparator(.hidden)
                .id("bottomID")
        }
    }
}
#endif
