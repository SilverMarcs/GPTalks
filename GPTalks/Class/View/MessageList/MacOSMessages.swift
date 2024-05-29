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

    var session: DialogueSession

    @State private var isUserScrolling = false
    @State var isShowSysPrompt: Bool = false

    var body: some View {
        ScrollViewReader { proxy in
            normalList
            .navigationTitle(session.title)
            .navigationSubtitle(navSubtitle)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                MacInputView(session: session)
                    .background(.bar)
                    .id(session.id)
            }
//            .onChange(of: viewModel.selectedDialogue) {
            .onAppear {
                if AppConfiguration.shared.alternateMarkdown {
                    scrollToBottom(proxy: proxy, animated: true, delay: 0.2)
                    scrollToBottom(proxy: proxy, animated: true, delay: 0.4)
                    if session.conversations.count > 8 {
                        scrollToBottom(proxy: proxy, animated: true, delay: 0.8)
                    }
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
                if !session.isReplying  {
                    isUserScrolling = false
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
                if session.isReplying {
                    isUserScrolling = true
                }
            }
            .onChange(of: session.resetMarker) {
                if session.resetMarker == session.conversations.count - 1 {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.errorDesc) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: session.inputImages) {
                if !session.inputImages.isEmpty {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.input) {
                scrollToBottom(proxy: proxy)
            }
            .onDrop(of: [UTType.image.identifier], isTargeted: nil) { providers -> Bool in
                if let itemProvider = providers.first {
                    itemProvider.loadObject(ofClass: NSImage.self) { (image, error) in
                        DispatchQueue.main.async {
                            if let image = image as? NSImage {
                                if session.isEditing {
                                    session.editingImages.append(image)
                                } else {
                                    session.inputImages.append(image)
                                }
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
                            Button("Reset Context") {
                                session.resetContext()
                            }
                            
                            Button("Delete All Messages") {
                                session.removeAllConversations()
                            }
                        }
                        
                        
                        Section {
                            ToolToggle(session: session)
                        }

                    } label: {
                        Image(systemName: "slider.vertical.3")
                    }
                    .menuIndicator(.hidden)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Group {
                        deleteLastMessage
                        
                        resetContextButton
                        
                        deleteAllMessages
                        
                        regenLast
                        
                        pasteImage
                    }
//                    .id(session.id)
                }
                ToolbarItemGroup {
                    ProviderPicker(session: session)

                    TempSlider(session: session)
                        .frame(width: 130)

                    ModelPicker(session: session)
                        .frame(width: 100)
                }
            }
            .sheet(isPresented: $isShowSysPrompt) {
                MacSysPrompt(session: session)
            }
        }
    }
    
    var navSubtitle: String {
        "Tokens: " + session.activeTokenCount.formatToK() + " • " + session.configuration.systemPrompt.truncated(to: 35)
    }
    
    @ViewBuilder
    private var normalList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(session.conversations) { conversation in
                    ConversationView(session: session, conversation: conversation)
                        .animation(.default, value: conversation.isReplying)
                }
            }
            
            ErrorDescView(session: session)
            
            Color.clear
                .frame(height: 30)
                .id("bottomID")
        
        }
    }
    
    private var deleteLastMessage: some View {
        Button("Delete Last Message") {
            if session.conversations.count > 0 {
                session.removeConversation(session.conversations.last!)
            }
        }
        .keyboardShortcut(.delete, modifiers: .command)
        .hidden()
    }
    
    private var resetContextButton: some View {
        Button("Reset Context") {
            session.resetContext()
        }
        .keyboardShortcut("k", modifiers: .command)
        .hidden()
    }
    
    private var deleteAllMessages: some View {
        Button("Delete all messages") {
            session.removeAllConversations()
        }
        .keyboardShortcut(.delete, modifiers: [.command, .shift])
        .hidden()
    }
    
    private var regenLast: some View {
        Button("Regenerate") {
            Task { @MainActor in
                await session.regenerateLastMessage()
            }
        }
        .keyboardShortcut("r", modifiers: .command)
        .hidden()
    }
    
    private var pasteImage: some View {
        Button("Paste Image") {
            session.pasteImageFromClipboard()
        }
        .keyboardShortcut("b", modifiers: .command)
        .hidden()
    }
}

struct MacSysPrompt: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var session: DialogueSession
    
    var body: some View {
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
                    dismiss()
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

struct ToolToggle: View {
    @Bindable var session: DialogueSession
    
    var body: some View {
        Menu {
            Toggle("GSearch", isOn: $session.configuration.useGSearch)
            Toggle("URL Scrape", isOn: $session.configuration.useUrlScrape)
            Toggle("Image Generate", isOn: $session.configuration.useImageGenerate)
            Toggle("Transcribe", isOn: $session.configuration.useTranscribe)
            Toggle("Extract PDF", isOn: $session.configuration.useExtractPdf)
            Toggle("Vision", isOn: $session.configuration.useVision)
        } label: {
            Text("Use Tools")
        }
    }
}

#endif
