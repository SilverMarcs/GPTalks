//
//  SessionToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI
import SwiftData

struct SessionToolbar: ToolbarContent {
    #if !os(macOS)
    @Environment(\.editMode) var editMode
    #endif
    @Environment(ChatSessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    
    @ObservedObject var config = AppConfig.shared
    
    var providers: [Provider]
    var addItemAction: (Provider) -> Void
    var getDefaultProvider: ([Provider]) -> Provider?
    
    var body: some ToolbarContent {
        #if !os(macOS)
        iosParts
        #endif
        
        ToolbarItem { Spacer() }
        
        ToolbarItem(placement: .automatic) {
            Menu {
                ForEach(providers) { provider in
                    Button(provider.name) {
                        addItemAction(provider)
                    }
                    .keyboardShortcut(.none)
                }
            } label: {
                Label("Add Item", systemImage: "square.and.pencil")
            } primaryAction: {
                if let provider = getDefaultProvider(providers) {
                    addItemAction(provider)
                }
            }
            .menuIndicator(.hidden)
            .popoverTip(NewSessionTip())
        }
    }
    
    #if !os(macOS)
    @State private var showSettings = false
    
    @ToolbarContentBuilder
    var iosParts: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                Button(action: { showSettings.toggle() }) {
                    Label("Settings", systemImage: "gear")
                }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
                    .labelStyle(.titleOnly)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    #endif
}
