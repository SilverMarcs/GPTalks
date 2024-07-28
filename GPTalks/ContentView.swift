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
    
    @State var showingInspector: Bool = true
    
    var body: some View {
        NavigationSplitView {
            SessionListSidebar()
        } detail: {
            ConversationListDetail()
        }
        #if !os(visionOS)
        .background(.background)
        #endif
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if providers.isEmpty {
                    let openAI = Provider.factory(type: .openai)
                    let anthropic = Provider.factory(type: .anthropic)
                    let google = Provider.factory(type: .google)
                    modelContext.insert(openAI)
                    modelContext.insert(anthropic)
                    modelContext.insert(google)
                    
                    if providerManager.getDefault(providers: providers) == nil {
                        providerManager.defaultProvider = openAI.id.uuidString
                    }
                    
                    if providerManager.getQuickProvider(providers: providers) == nil {
                        providerManager.quickProvider = openAI.id.uuidString
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
        .environment(SessionVM(providerManager: ProviderManager.shared))
}
