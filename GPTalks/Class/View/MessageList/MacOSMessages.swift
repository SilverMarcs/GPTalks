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

    @State private var previousContent: String?
    @State private var isUserScrolling = false
    @State private var contentChangeTimer: Timer? = nil

    @FocusState var isTextFieldFocused: Bool

    var body: some View {
        ScrollViewReader { proxy in
            normalList
            .navigationTitle(session.title)
            .navigationSubtitle("Context: \(session.getMessageCountAfterResetMarker())/\(session.configuration.contextLength)")
            .toolbar {
                ToolbarItems(session: session)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomInputView(
                    session: session,
                    focused: _isTextFieldFocused
                )
                .background(.bar)
            }
            .onChange(of: viewModel.selectedDialogue) {
                isTextFieldFocused = true
                
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
                if session.conversations.last?.content != previousContent && !isUserScrolling {
                    scrollToBottom(proxy: proxy, animated: true)
                }
                previousContent = session.conversations.last?.content

                contentChangeTimer?.invalidate()
                contentChangeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    isUserScrolling = false
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSScrollView.willStartLiveScrollNotification)) { _ in
                isUserScrolling = true
            }
            .onChange(of: session.isAddingConversation) {
                scrollToBottom(proxy: proxy, animated: true)
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
            .onChange(of: session.inputImage) {
                if session.inputImage != nil {
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
                    session.configuration.model = session.configuration.provider.preferredModel
                }
            }
            .onDrop(of: [UTType.image.identifier], isTargeted: nil) { providers -> Bool in
                if let itemProvider = providers.first {
                    itemProvider.loadObject(ofClass: NSImage.self) { (image, error) in
                        DispatchQueue.main.async {
                            if let image = image as? NSImage {
                                session.inputImage = image
                            } else {
                                print("Could not load image: \(String(describing: error))")
                            }
                        }
                    }
                    return true
                }
                return false
            }
        }
    }

    private var normalList: some View {
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
