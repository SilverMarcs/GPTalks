//
//  iOSMessages.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

#if !os(macOS)
import SwiftUI
import UniformTypeIdentifiers
#if !os(visionOS)
import VisualEffectView
#endif

struct iOSMessages: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
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
                    VStack(spacing: 0) {
                        ForEach(session.conversations) { conversation in
                            ConversationView(session: session, conversation: conversation)
                        }
                    }
                    .padding(.bottom, 8)

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
            .scrollDismissesKeyboard(.immediately)
            #endif
            .listStyle(.plain)
            .onAppear {
//                scrollToBottom(proxy: proxy, animated: false)
                
                scrollToBottom(proxy: proxy, delay: 0.3)
                
                if AppConfiguration.shared.alternateMarkdown && session.conversations.count > 8 {
                    scrollToBottom(proxy: proxy, delay: 0.8)
                }
            }
            .onTapGesture {
                isTextFieldFocused = false
            }
            .onChange(of: isTextFieldFocused) {
                if isTextFieldFocused {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: session.input) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: session.resetMarker) {
                if session.resetMarker == session.conversations.count - 1 {
                    scrollToBottom(proxy: proxy)
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
            .onChange(of: session.inputImages) {
                if !session.inputImages.isEmpty {
                    scrollToBottom(proxy: proxy, animated: true)
                }
            }
            .onChange(of: session.isAddingConversation) {
                scrollToBottom(proxy: proxy)
            }
//            .onDrop(of: [UTType.image.identifier], isTargeted: nil) { providers -> Bool in
//                if let itemProvider = providers.first {
//                    itemProvider.loadObject(ofClass: UIImage.self) { image, error in
//                        DispatchQueue.main.async {
//                            if let image = image as? UIImage {
//                                if session.isEditing {
//                                    session.editingImages.append(image)
//                                } else {
//                                    session.inputImages.append(image)
//                                }
//                            } else {
//                                print("Could not load image: \(String(describing: error))")
//                            }
//                        }
//                    }
//                    return true
//                }
//                return false
//            }
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
                    Text("Searched:")
                        .bold()
                        .font(.callout)
                    Text(viewModel.searchText)
                        .font(.callout)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            viewModel.searchText = ""
                        }
                    } label: {
                        Text("Clear")
                    }
                }
                .padding(10)
                .background(.bar)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            IOSInputView(
                session: session,
                focused: _isTextFieldFocused
            )
#if !os(visionOS)
            .background(
                VisualEffect(colorTint: colorScheme == .dark ? .black : .white, colorTintAlpha: 0.7, blurRadius: 8, scale: 1)
                    .ignoresSafeArea()
            )
#else
            .background(.bar)
#endif
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(session.configuration.model.name)
        .toolbarTitleMenu {
            Section(navSubtitle) {
                Menu {
                    ProviderPicker(session: session)
                } label: {
                    Label(session.configuration.provider.name, systemImage: "building.2")
                }

                Menu {
                    ModelPicker(session: session)
                } label: {
                    Label(session.configuration.model.name, systemImage: "cube.box")
                }

                Menu {
                    TempPicker(session: session)
                } label: {
                    Label("Temperature: " + String(session.configuration.temperature), systemImage: "thermometer.sun")
                }
            }
            
            Section {
                ToolToggle(session: session)
            }
        }
        .toolbar {
//            ToolbarItem(placement: .principal) {
//                navTitle
//            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Section {
                        Menu {
                            Button {
                                Task { await session.generateTitle(forced: true) }
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
                            Label(session.title, systemImage: "textformat.alt")
                        }

                        Menu {
                            Button {
                                showSysPromptSheet.toggle()
                            } label: {
                                Label("Edit", systemImage: "rectangle.and.pencil.and.ellipsis")
                            }

                        } label: {
                            Label(session.configuration.systemPrompt, systemImage: "square.text.square")
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
//        HStack {
//            ProviderImage(radius: 9, color: session.configuration.provider.accentColor, frame: 29)
//            
//            VStack(alignment: .leading, spacing: 1) {
//                Text(session.title)
//                    .font(.system(size: 16))
//                    .foregroundStyle(.primary)
//                    .bold()
//                
//                Text(session.configuration.model.name + " • " + session.configuration.systemPrompt)
//                    .font(.system(size: 11))
//                    .foregroundStyle(.secondary)
//            }
//            
//            Spacer()
//        }
        
        Menu {
            Section(navSubtitle) {
                Menu {
                    ProviderPicker(session: session)
                } label: {
                    Label(session.configuration.provider.name, systemImage: "building.2")
                }

                Menu {
                    ModelPicker(session: session)
                } label: {
                    Label(session.configuration.model.name, systemImage: "cube.box")
                }

                Menu {
                    TempPicker(session: session)
                } label: {
                    Label("Temperature: " + String(session.configuration.temperature), systemImage: "thermometer.sun")
                }
            }
            
            Section {
                ToolToggle(session: session)
            }
            
        } label: {
            HStack {
                Text(session.configuration.model.name)
                    .bold()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 9))
                    .padding(.top, 2)
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.primary)
    }

    private var navSubtitle: String {
        "Tokens: " + session.activeTokenCount.formatToK()
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
                .foregroundStyle(.foreground.secondary, .ultraThickMaterial)
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
