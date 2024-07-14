//
//  QuickPanel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/07/2024.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts

#if os(macOS)
struct QuickPanel: View {
    @Environment(\.modelContext) var modelContext
    @Environment(SessionVM.self) var sessionVM
    @ObservedObject var providerManager = ProviderManager.shared
    
    @Query(sort: \Provider.date, order: .reverse) var providers: [Provider]
    
    @State var prompt: String = ""
    @Binding var showAdditionalContent: Bool
    
    @State var session: Session = Session()
    
    @FocusState private var isFocused: Bool
    
    let dismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            textfieldView
                .padding(15)
                .padding(.leading, 2)
                .onAppear {
                    session = sessionVM.addQuickItem(providerManager: providerManager, providers: providers, modelContext: modelContext)
                }
            
            if showAdditionalContent {
                Divider()
                
                conversationView
                    .padding()
                
                bottomView
            }
        }
    }
    
    private var textfieldView: some View {
        HStack(spacing: 12) {
            Menu {
                Picker("Provider", selection: $session.config.provider) {
                    ForEach(providers.sorted(by: { $0.date < $1.date }), id: \.self) { provider in
                        Text(provider.name).tag(provider.id)
                    }
                }
                
                Picker("Model", selection: $session.config.model) {
                    ForEach(session.config.provider.models.sorted(by: { $0.name < $1.name }), id: \.self) { model in
                        Text(model.name)
                    }
                }
                .onChange(of: session.config.provider) {
                    session.config.model = session.config.provider.quickChatModel
                }
                
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            
            TextField("Ask Anything...", text: $prompt)
                .focused($isFocused)
                .font(.system(size: 25))
                .textFieldStyle(.plain)
            
            if session.isReplying {
                StopButton(size: 28) {
                    session.stopStreaming()
                }
            } else {
                SendButton(size: 28) {
                    send()
                }
            }
        }
    }
    
    private var conversationView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(session.groups) { group in
                        ConversationGroupView(group: group)
                    }
                }
                .onChange(of: session.groups.count) {
                    withAnimation {
                        proxy.scrollTo(session.groups.last, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var bottomView: some View {
        HStack {
            Group {
                Button {
                    resetChat()
                } label: {
                    Image(systemName: "delete.left")
                        .imageScale(.medium)
                }
                .keyboardShortcut(.delete, modifiers: [.command])
                
                Group {
                    Text(session.config.provider.name.uppercased())
                    
                    Text(session.config.model.name)
                }
                .font(.caption)
                
                Spacer()
                
                Button {
                    addToDB()
                } label: {
                    Image(systemName: "plus.square.on.square")
                        .imageScale(.medium)
                }
                .keyboardShortcut("N", modifiers: [.command])
                
            }
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
            .padding(7)
        }
        .background(.regularMaterial)
    }
    
    private func resetChat() {
        showAdditionalContent = false
        session.deleteAllConversations()
        //        session.configuration = .init(quick: true)
    }
    
    private func addToDB() {
        if session.groups.isEmpty {
            return
        }
        
        dismiss()
        session.isQuick = false
        
        NSApp.activate(ignoringOtherApps: true)
        NSApp.keyWindow?.makeKeyAndOrderFront(nil)
        
        self.session = sessionVM.addQuickItem(providerManager: providerManager, providers: providers, modelContext: modelContext)
        showAdditionalContent = false
    }
    
    private func send() {
        if prompt.isEmpty {
            return
        }
        
        showAdditionalContent = true
        
        session.inputManager.prompt = prompt
        
        Task { @MainActor in
            await session.sendInput()
        }
        
        prompt = ""
    }
}

#Preview {
    let showAdditionalContent = Binding.constant(true)
    let dismiss = {}
    
    QuickPanel(showAdditionalContent: showAdditionalContent, dismiss: dismiss)
}
#endif
