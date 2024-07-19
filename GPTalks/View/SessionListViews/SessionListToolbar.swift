//
//  SessionListToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import SwiftUI
import SwiftData

struct SessionListToolbar: ToolbarContent {
    #if !os(macOS)
    @Environment(\.editMode) var editMode
    #endif
    @Environment(SessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    @ObservedObject var providerManager = ProviderManager.shared
    
    @Query(sort: \Provider.date, order: .reverse) var providers: [Provider]
    @Query var sessions: [Session]
    @Query var imageSessions: [ImageSession]
    
    @State var showSettings: Bool = false
    
    var body: some ToolbarContent {
#if !os(macOS)
        ToolbarItem(placement: .navigationBarLeading) {
            if editMode?.wrappedValue == .inactive {
                Menu {
                    Button(action: { withAnimation { editMode?.wrappedValue = .active }}) {
                        Label("Edit", systemImage: "pencil")
                    }
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
            } else {
                Button(action: { withAnimation {editMode?.wrappedValue = .inactive }}) {
                    Label("Done", systemImage: "pencil")
                        .labelStyle(.titleOnly)
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
        if sessionVM.state == .chats {
            sessionVM.addItem(sessions: sessions, providerManager: providerManager, providers: providers, modelContext: modelContext)
        } else {
            sessionVM.addimageSession(imageSessions: imageSessions, providerManager: providerManager, providers: providers, modelContext: modelContext)
        }
    }
}

#Preview {
    VStack {
        Text("Hi")
    }.toolbar  {
        SessionListToolbar()
    }
}
