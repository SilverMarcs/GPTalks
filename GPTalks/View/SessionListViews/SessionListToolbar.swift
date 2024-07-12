//
//  SessionListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI
import SwiftData

struct SessionListToolbar: ToolbarContent {
    @Environment(SessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    @ObservedObject var providerManager = ProviderManager.shared
    
    @Query(sort: \Provider.date, order: .reverse) var providers: [Provider]
    
    @State var showSettings: Bool = false
    
    var body: some ToolbarContent {
#if !os(macOS)
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { showSettings.toggle() }) {
                Label("Settings", systemImage: "gear")
            }
            .labelStyle(.titleOnly)
            .popover(isPresented: $showSettings) {
                NavigationStack {
                    SettingsView()
                        .navigationTitle("Settings")
                        .toolbarTitleDisplayMode(.inline)
                        .toolbar {
                            Button("Done") {
                                showSettings.toggle()
                            }
                        }
                }
            }
        }
#endif
        ToolbarItem {
            Spacer()
        }
        
        ToolbarItem(placement: .automatic) {
            Button(action: addItem) {
                Label("Add Item", systemImage: "square.and.pencil")
            }
            .keyboardShortcut("n", modifiers: .command)
        }
    }
    
    private func addItem() {
        sessionVM.addItem(providerManager: providerManager, providers: providers, modelContext: modelContext)
    }
}

#Preview {
    VStack {
        Text("Hi")
    }.toolbar  {
        SessionListToolbar()
    }
}
