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
    
    @State var editingIndex: Int = 0

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(session.conversations) { conversation in
                        ConversationView(session: session, conversation: conversation) {
                            proxy.scrollTo(conversation.id, anchor: .top)
                        }
                        .id(conversation.id.uuidString)
                        .animation(.default, value: conversation.isReplying)
                    }
                }
                
                ErrorDescView(session: session)
                
                Color.clear
                    .frame(height: 30)
                    .id("bottomID")
            }
            .scrollContentBackground(.visible)
            .navigationTitle(session.title)
            .navigationSubtitle(navSubtitle)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                MacInputView(session: session)
                    .background(.bar)
                    .id(session.id)
            }
            .onAppear {
                scrollToBottom(proxy: proxy, animated: true, delay: 0.2)
                scrollToBottom(proxy: proxy, animated: true, delay: 0.4)
                if session.conversations.count > 8 {
                    scrollToBottom(proxy: proxy, animated: true, delay: 0.8)
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
            .onChange(of: session.isEditing) {
                if session.isEditing {
                    withAnimation {
                        proxy.scrollTo(session.conversations[session.editingIndex].id.uuidString, anchor: .top)
                    }
                }
            }
            .onDrop(of: [UTType.image.identifier], isTargeted: nil) { providers -> Bool in
                if let itemProvider = providers.first {
                    itemProvider.loadObject(ofClass: NSImage.self) { (image, error) in
                        DispatchQueue.main.async {
                            if let image = image as? NSImage {
                                if let filePath = saveImage(image: image) {
                                    if session.isEditing {
                                        if !session.editingImages.contains(filePath) {
                                            session.editingImages.append(filePath)
                                        }
                                    } else {
                                        if !session.inputImages.contains(filePath) {
                                            session.inputImages.append(filePath)
                                        }
                                    }
                                } else {
                                    print("Failed to save image to disk")
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
                            ExportMenu(session: session)
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
                }
                ToolbarItemGroup {
                    ProviderPicker(session: session)

                    TempSlider(session: session)
                        .frame(width: 130)

                    ModelPicker(session: session)
                        .frame(width: 100)
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        isShowSysPrompt = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .popover(isPresented: $isShowSysPrompt) {
                        MacSysPrompt(session: session)
                    }
                }
            }
        }
    }
    
    var navSubtitle: String {
        session.configuration.systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines).truncated(to: 45)
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
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            GroupBox("Title") {

                TextField("Title", text: $session.title)
                    .focused($isFocused)
                    .onAppear {
                        DispatchQueue.main.async {
                            isFocused = false
                        }
                    }
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 3)
                    .frame(width: 300)
            }
            
            GroupBox("System Prompt") {
                TextField("System Prompt", text: $session.configuration.systemPrompt, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 3)
                    .frame(width: 300)
                    .lineLimit(7, reservesSpace: true)
            }
        }
        .padding(13)
    }
}

struct ExportMenu: View {
    var session: DialogueSession
    @State private var isShowExport = false
    @State private var pathStr = "Downloads/"
    
    var body: some View {
        Menu {
            
            Button("Markdown") {
                if let path = session.exportToMd() {
                    pathStr = path
                    isShowExport = true
                }
            }
        } label: {
            Label("Export", systemImage: "square.and.arrow.up")
        }
        .alert(isPresented: $isShowExport) {
            // TODO: this isnt perfect
            Alert(title: Text("Notice"), message: Text("Exported as \(pathStr)"), dismissButton: .default(Text("OK")))
        }
    }
}


#endif

