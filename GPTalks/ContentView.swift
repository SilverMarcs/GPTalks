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
    // TODO: Maybe just use modelfconetxt to fetch since one time only
    @Query private var providers: [Provider]

    @ObservedObject var providerManager = ProviderManager.shared
    
#if os(macOS)
    @State var showingPanel = false
    @State private var mainWindow: NSWindow?
    @State var showAdditionalContent = false
#endif
    
    @State var showingInspector: Bool = true
    
    var body: some View {
        NavigationSplitView {
            SessionListSidebar()
                .navigationSplitViewColumnWidth(min: 240, ideal: 250, max: 300)
        } detail: {
            ConversationListDetail()
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        .background(BackgroundView(window: $mainWindow))
        .task {
            if providers.isEmpty {
                let openAI = Provider.factory(type: .openai)
                openAI.order = 0
                let anthropic = Provider.factory(type: .anthropic)
                anthropic.order = 1
                let google = Provider.factory(type: .google)
                google.order = 2
                
                modelContext.insert(openAI)
                modelContext.insert(anthropic)
                modelContext.insert(google)
                
                ProviderManager.shared.defaultProvider = openAI.id.uuidString
                ProviderManager.shared.quickProvider = openAI.id.uuidString
            }
            
            KeyboardShortcuts.onKeyDown(for: .togglePanel) {
                if !NSApp.isActive {
                    NSApp.activate(ignoringOtherApps: true)
                }
                showingPanel.toggle()
            }
        }
        .floatingPanel(isPresented: $showingPanel, showAdditionalContent: $showAdditionalContent) {
            QuickPanelHelper(showAdditionalContent: $showAdditionalContent, showingPanel: $showingPanel) {
                showingPanel.toggle()
                bringMainWindowToFront()
            }
            .modelContainer(modelContext.container)
            .environment(sessionVM)
        }
        .inspector(isPresented: $showingInspector) {
            InspectorView(showingInspector: $showingInspector)
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
