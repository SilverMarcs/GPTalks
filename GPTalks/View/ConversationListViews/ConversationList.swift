//
//  ConversationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct ConversationList: View {
    var session: Session
    var isQuick: Bool = false
    
    @ObservedObject var config: AppConfig = AppConfig.shared
    
    @Environment(\.modelContext) var modelContext
    @Environment(SessionVM.self) private var sessionVM
    
    @State private var hasUserScrolled = false
    @State var showingInspector: Bool = false
    
    @State private var isExportingJSON = false
    @State private var isExportingMarkdown = false
    
    var body: some View {
        ScrollViewReader { proxy in
            Group {
                if config.markdownProvider == .webview {
                    vStackView
                } else {
                    listView
                }
            }
            .onAppear {
                session.proxy = proxy
            }
            #if os(macOS)
            .navigationSubtitle( session.config.systemPrompt.trimmingCharacters(in: .newlines).truncated(to: 45))
            .navigationTitle(session.title)
            .toolbar {
                ConversationListToolbar(session: session)
            }
            #else
            #if !os(visionOS)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                let bottomReached = value > UIScreen.main.bounds.height
                hasUserScrolled = bottomReached
            }
            .scrollDismissesKeyboard(.immediately)
            #endif
            .onTapGesture {
                showingInspector = false
            }
            .toolbar {
                showInspector
            }
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle(session.config.model.name)
            .toolbarTitleMenu {
                exportButtons
            }
            #endif
            .applyObservers(proxy: proxy, session: session, hasUserScrolled: $hasUserScrolled)
            .scrollContentBackground(.visible)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isQuick {
                    ChatInputView(session: session)
                } else {
                    EmptyView()
                }
            }
            #if os(iOS)
            .inspector(isPresented: $showingInspector) {
                InspectorView(showingInspector: $showingInspector)
            }
            #elseif os(visionOS)
            .sheet(isPresented: $showingInspector) {
                NavigationStack {
                    InspectorView(showingInspector: $showingInspector)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                DismissButton()
                            }
                        }
                }

            }
            #endif
            .onDrop(of: [UTType.image.identifier], isTargeted: nil) { providers -> Bool in
                session.inputManager.handleImageDrop(providers)
                return true
            }
        }
    }
    
    var listView : some View {
        List {
            commonCollection
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    var vStackView: some View  {
        ScrollView {
            VStack(spacing: spacing) {
                commonCollection
            }
            .padding()
            .padding(.top, -5)
        }
    }
    
    @ViewBuilder
    var commonCollection: some View {
        ForEach(session.groups, id: \.self) { group in
            ConversationGroupView(group: group)
        }
        .listRowSeparator(.hidden)

        ErrorMessageView(session: session)
            .listRowSeparator(.hidden)
        
        colorSpacer
            .listRowSeparator(.hidden)
    }
    
    var colorSpacer: some View {
        #if os(macOS)
        Color.clear
            .frame(height: spacerHeight)
            .id(String.bottomID)
        #else
        GeometryReader { geometry in
            Color.clear
                .frame(height: spacerHeight)
                .id(String.bottomID)
                .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
        }
        #endif
    }
    
    @ViewBuilder
    var exportButtons: some View {
        Button {
            isExportingJSON = true
        } label: {
            Label("Export JSON", systemImage: "ellipsis.curlybraces")
        }
        
        Button {
            isExportingMarkdown = true
        } label: {
            Label("Export Markdown", systemImage: "richtext.page")
        }
    }
    
    #if !os(macOS)
    private var showInspector: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                showingInspector.toggle()
                
            } label: {
                Label("Show Inspector", systemImage: "info.circle")
            }
        }
    }
    #endif
    
    var spacerHeight: CGFloat {
        #if os(macOS)
        if config.markdownProvider == .webview {
            20
        } else {
            1
        }
        #else
        10
        #endif
    }
    
    var spacing: CGFloat {
        #if os(macOS)
        0
        #else
        15
        #endif
    }
    
    var navSubtitle: String {
        "Tokens: "
        + session.tokenCounter.formatToK()
        + " • " + session.config.systemPrompt.trimmingCharacters(in: .newlines).truncated(to: 45)
    }
}

#Preview {
    let config = SessionConfig()
    let session = Session(config: config)
    
    ConversationList(session: session)
        .environment(SessionVM())
}
