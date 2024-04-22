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
    @State var keyDownMonitor: Any?

    var body: some View {
        // TODO: create variable for nav subtitle
        
        ScrollViewReader { proxy in
            listView
            .navigationTitle(session.title)
//            .navigationSubtitle(session.configuration.systemPrompt.truncated(to: 40))
            .navigationSubtitle(navSubtitle)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                MacInputView(session: session)
                    .background(.bar)
                    .id(session.id)
            }
            .onChange(of: viewModel.selectedDialogue) {      
//            .onAppear {
                if AppConfiguration.shared.alternateMarkdown {
                    scrollToBottom(proxy: proxy, animated: true, delay: 0.2)
                    scrollToBottom(proxy: proxy, animated: true, delay: 0.4)
                    if session.conversations.count > 8 {
                        scrollToBottom(proxy: proxy, animated: true, delay: 0.8)
                    }
                } else {
                    scrollToBottom(proxy: proxy, animated: false)
                }
                
                // Remove previous event monitor if exists
                if let existingMonitor = self.keyDownMonitor {
                    NSEvent.removeMonitor(existingMonitor)
                    self.keyDownMonitor = nil
                }

                // Add new event monitor
                self.keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
                    if event.modifierFlags.contains(.command) && event.characters == "v" {
                        session.pasteImageFromClipboard()
                    }
                    return event
                }
            }
            .onDisappear {
                if let existingMonitor = self.keyDownMonitor {
                    NSEvent.removeMonitor(existingMonitor)
                    self.keyDownMonitor = nil
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
                scrollToBottom(proxy: proxy, animated: true)
            }
            .onChange(of: session.inputImages) {
                if !session.inputImages.isEmpty {
                    scrollToBottom(proxy: proxy, animated: true)
                }
            }
            .onChange(of: session.input) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: session.isAddingConversation) {
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

                #if os(macOS)
                ToolbarItem(placement: .keyboard) {
                    deleteLastMessage
                }
                ToolbarItem(placement: .keyboard) {
                    resetContextButton
                }
                ToolbarItem(placement: .keyboard) {
                    deleteAllMessages
                }
                ToolbarItem(placement: .keyboard) {
                    regenLast
                }
                #endif
                
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
    private var listView: some View {
        if AppConfiguration.shared.smootherScrolling {
            alternateList
        } else {
            normalList
        }
    }

    @ViewBuilder
    private var alternateList: some View {
        List {
            VStack(spacing: 0) {
                ForEach(session.filteredConversations()) { conversation in
                    ConversationView(session: session, conversation: conversation)
                }
                
                ErrorDescView(session: session)
            }
            .padding(.horizontal, -8)
            .padding(.bottom, 30)
            .id("bottomID")
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private var normalList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(session.filteredConversations()) { conversation in
                    ConversationView(session: session, conversation: conversation)
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
            if let session = viewModel.selectedDialogue {
                if session.conversations.count > 0 {
                    session.removeConversation(session.conversations.last!)
                }
            }
        }
        .keyboardShortcut(.delete, modifiers: .command)
        .hidden()
    }
    
    private var resetContextButton: some View {
        Button("Reset Context") {
            if let session = viewModel.selectedDialogue {
                session.resetContext()
            }
        }
        .keyboardShortcut("k", modifiers: .command)
        .hidden()
    }
    
    private var deleteAllMessages: some View {
        Button("Delete all messages") {
            if let session = viewModel.selectedDialogue {
                session.removeAllConversations()
            }
        }
        .keyboardShortcut(.delete, modifiers: [.command, .shift])
        .hidden()
    }
    
    private var regenLast: some View {
        Button("Regenerate") {
            if let session = viewModel.selectedDialogue {
                Task { @MainActor in
                    await session.regenerateLastMessage()
                }
            }
        }
        .keyboardShortcut("r", modifiers: .command)
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
        Toggle("Use Tools", isOn: $session.configuration.useTools)
    }
}

#endif

