//
//  ContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts

struct ContentView: View {
    @Environment(SessionVM.self) private var sessionVM
    @Environment(\.modelContext) private var modelContext
    @Query private var providers: [Provider]

    @ObservedObject var providerManager = ProviderManager.shared
    
#if os(macOS)
    @State var showingPanel = false
    @State private var mainWindow: NSWindow?
    @State var showAdditionalContent = false
#endif
    
    var body: some View {
        NavigationSplitView {
            SessionListSidebar()
        } detail: {
            ConversationListDetail()
        }
        .background(.background)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if providers.isEmpty {
                    let newProvider = Provider.factory(type: .openai)
                    modelContext.insert(newProvider)
                    
                    if providerManager.getDefault(providers: providers) == nil {
                        providerManager.defaultProvider = newProvider.id.uuidString
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 600, minHeight: 400)
        .background(BackgroundView(window: $mainWindow))
        .task {
            KeyboardShortcuts.onKeyDown(for: .togglePanel) {
                if !NSApp.isActive {
                    NSApp.activate(ignoringOtherApps: true)
                }
                showingPanel.toggle()
            }
        }
        .floatingPanel(isPresented: $showingPanel, showAdditionalContent: $showAdditionalContent) {
            QuickPanel(showAdditionalContent: $showAdditionalContent) {
                showingPanel.toggle()
                bringMainWindowToFront()
            }
            .modelContainer(modelContext.container)
            .environment(sessionVM)
        }
        #endif
    }
    
#if os(macOS)
    private func bringMainWindowToFront() {
        if let window = mainWindow, !window.isKeyWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
#endif
}

#if os(macOS)
struct BackgroundView: NSViewRepresentable {
    @Binding var window: NSWindow?
    
    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async {
            self.window = nsView.window
        }
        return nsView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif

#Preview {
    ContentView()
        .modelContainer(for: Session.self, inMemory: true)
        .environment(SessionVM())
}
