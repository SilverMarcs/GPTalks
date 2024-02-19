//
//  iOSMessages.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

#if !os(macOS)
import SwiftUI
import UniformTypeIdentifiers
import VisualEffectView

struct iOSMessages: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(DialogueViewModel.self) private var viewModel

    @Bindable var session: DialogueSession

    @State private var shouldStopScroll: Bool = false
    @State private var showScrollButton: Bool = false

    @State private var showSysPromptSheet: Bool = false

    @State private var showRenameDialogue = false
    @State private var newName = ""

    @FocusState var isTextFieldFocused: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    Spacer()
                        .frame(height: 12)

                    ForEach(session.conversations) { conversation in
                        ConversationView(session: session, conversation: conversation)
                    }
                    .padding(.horizontal, AppConfiguration.shared.alternatChatUi ? 0 :  12)

                    ErrorDescView(session: session)

                    ScrollSpacer

                    GeometryReader { geometry in
                        Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
                    }
                }

                scrollBtn(proxy: proxy)
            }
            #if !os(visionOS)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                let bottomReached = value > UIScreen.main.bounds.height
                shouldStopScroll = bottomReached
                showScrollButton = bottomReached
            }
            .scrollDismissesKeyboard(.interactively)
            #endif
            .listStyle(.plain)
            .onAppear {
                if AppConfiguration.shared.alternateMarkdown {
                    scrollToBottom(proxy: proxy, animated: true, delay: 0.2)
                    scrollToBottom(proxy: proxy, animated: true, delay: 0.4)
                    scrollToBottom(proxy: proxy, animated: true, delay: 0.8)
                } else {
                    scrollToBottom(proxy: proxy, animated: false)
                }
            }
            .onTapGesture {
                isTextFieldFocused = false
            }
            .onChange(of: isTextFieldFocused) {
                if !isTextFieldFocused {
                    scrollToBottom(proxy: proxy, delay: 0.2)
                }
            }
            .onChange(of: session.input) {
                if session.input.contains("\n") || (session.input.count > 25) || (session.input.isEmpty) {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.resetMarker) {
                if session.resetMarker == session.conversations.count - 1 {
                    scrollToBottom(proxy: proxy)
                }

                if session.containsConversationWithImage {
                    session.configuration.model = session.configuration.provider.visionModels[0]
                }
            }
            .onChange(of: session.errorDesc) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: session.conversations.last?.content) {
                if !shouldStopScroll {
                    scrollToBottom(proxy: proxy, animated: true)
                }
            }
            .onChange(of: session.conversations.count) {
                shouldStopScroll = false
            }
            .onChange(of: session.isAddingConversation) {
                scrollToBottom(proxy: proxy)
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
                    itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        DispatchQueue.main.async {
                            if let image = image as? UIImage {
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
            .alert("Rename Session", isPresented: $showRenameDialogue) {
                TextField("Enter new name", text: $newName)
                Button("Rename", action: {
                    session.rename(newTitle: newName)
                })
                Button("Cancel", role: .cancel, action: {})
            }
            .sheet(isPresented: $showSysPromptSheet) {
                sysPromptSheet
            }
        }
        .safeAreaInset(edge: .top) {
            if !viewModel.searchText.isEmpty {
                HStack {
                    Text("Clear Search Results")
                        .font(.callout)
                    Spacer()
                    Button {
                        withAnimation {
                            viewModel.searchText = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(10)
                .background(.bar)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomInputView(
                session: session,
                focused: _isTextFieldFocused
            )
            #if os(iOS)
            .background(
                VisualEffect(colorTint: colorScheme == .dark ? .black : .white, colorTintAlpha: 0.8, blurRadius: 18, scale: 1)
                    .ignoresSafeArea()
            )
            #else
            .background(.regularMaterial)
            #endif
        }
        #if os(visionOS)
        .navigationTitle(session.title)
        #endif
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                navTitle
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Section {
                        Menu {
                            Button {
                                Task { await session.generateTitle() }
                            } label: {
                                Label("Generate", systemImage: "wand.and.stars")
                            }

                            Button {
                                newName = session.title
                                showRenameDialogue.toggle()
                            } label: {
                                Label("Rename", systemImage: "rectangle.and.pencil.and.ellipsis")
                            }

                        } label: {
                            Label("Title", systemImage: "textformat.alt")
                        }

                        Menu {
                            Button {
                                showSysPromptSheet.toggle()
                            } label: {
                                Label("Edit", systemImage: "rectangle.and.pencil.and.ellipsis")
                            }

                        } label: {
                            Label("System Prompt", systemImage: "square.text.square")
                        }
                    }

                    Section {
                        Menu {
                            ProviderPicker(session: session)
                        } label: {
                            Label("Provider", systemImage: "building.2")
                        }

                        Menu {
                            ModelPicker(session: session)
                        } label: {
                            Label("Model", systemImage: "cube.box")
                        }

                        Menu {
                            TempPicker(session: session)
                        } label: {
                            Label("Temperature", systemImage: "thermometer.sun")
                        }

                        Menu {
                            ContextPicker(session: session)
                        } label: {
                            Label("Context", systemImage: "clock.arrow.circlepath")
                        }
                    }

                    Section {
                        Menu {
                            Button(role: .destructive) {
                                session.removeAllConversations()
                            } label: {
                                Label("All Messages", systemImage: "trash")
                            }
                        } label: {
                            Label("Delete Messages", systemImage: "trash")
                        }
                    }
                } label: {
                    Label("Config", systemImage: "ellipsis.circle")
                }
            }
        }
    }

    private var navTitle: some View {
        HStack {
            ProviderImage(radius: 9, color: session.configuration.provider.accentColor, frame: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text(session.isGeneratingTitle ? "Generating Title..." : session.title)
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                    .bold()
                
                HStack(spacing: 3) {
                    Text(session.configuration.systemPrompt)
                        .frame(maxWidth: 200, alignment: .leading)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }

    private var ScrollSpacer: some View {
        Spacer()
            .id("bottomID")
            .onAppear {
                showScrollButton = false
            }
            .onDisappear {
                showScrollButton = true
            }
    }

    private func scrollBtn(proxy: ScrollViewProxy) -> some View {
        Button {
            scrollToBottom(proxy: proxy)
        } label: {
            Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(.ultraThickMaterial)
                .background(Color.primary.opacity(0.8))
                .shadow(radius: 3)
                .clipShape(Circle())
                .padding(.bottom, 15)
                .padding(.trailing, 15)
        }
        .opacity(showScrollButton ? 1 : 0)
    }

    private var sysPromptSheet: some View {
        NavigationView {
            Form {
                TextField("System Prompt", text: $session.configuration.systemPrompt, axis: .vertical)
                    .lineLimit(4, reservesSpace: true)
            }
            .navigationTitle("System Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    showSysPromptSheet = false
                }
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#endif
