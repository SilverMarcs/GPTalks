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
    
    @Query var providers: [Provider]
    
    @Query var sessions: [Session]
    @Query var imageSessions: [ImageSession]
    
    @State var showSettings: Bool = false
    @State var showDefaultProviderAlert: Bool = false
    
    var body: some ToolbarContent {
#if !os(macOS)
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                if editMode?.wrappedValue == .inactive {
                    Button {
                        withAnimation {
                            editMode?.wrappedValue = .active
                            sessionVM.chatCount = .max
                        }
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
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
        }
        
        
        if editMode?.wrappedValue == .active {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        withAnimation {
                            editMode?.wrappedValue = .inactive
                            sessionVM.chatCount = 12
                        }
                    } label: {
                        Text("Done")
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            for session in sessionVM.selections {
                                session.isStarred.toggle()
                            }
                        } label: {
                            Label("Toggle Starred", systemImage: "star")
                        }
                        
                        Section {
                            Button {
                                sessionVM.selections = Set(sessions)
                            } label: {
                                Label("Select All", systemImage: "checkmark.circle")
                            }
                            
                            Button {
                                sessionVM.selections = []
                            } label: {
                                Label("Deselect All", systemImage: "xmark.circle")
                            }
                        }
                        
                        Button(role: .destructive) {
                            for session in sessionVM.selections {
                                modelContext.delete(session)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Label("Actions", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
#endif
        ToolbarItem {
            Spacer()
        }
        
        ToolbarItem(placement: .automatic) {
            Menu {
                ForEach(providers
                    .filter {
                        $0.isEnabled &&
                        (sessionVM.state != .images || !$0.imageModels.isEmpty)
                    }
                    .sorted { $0.order < $1.order }) { provider in
                        Button(provider.name) {
                            addItem(provider: provider)
                        }
                        .keyboardShortcut(.none)
                }
            } label: {
                Label("Add Item", systemImage: "square.and.pencil")
            } primaryAction: {
                if let provider = getDefaultProvider(providers: providers) {
                    addItem(provider: provider)
                } else {
                    showDefaultProviderAlert.toggle()
                }
            }
            .keyboardShortcut("n", modifiers: [.command])
            .menuIndicator(.hidden)
            .alert("Set Default Provider in Settings", isPresented: $showDefaultProviderAlert) { }
        }
    }
    
    private func addItem(provider: Provider) {
        sessionVM.addItem(provider: provider, sessions: sessions, imageSessions: imageSessions, modelContext: modelContext)
    }
}

#Preview {
    VStack {
        Text("Hi")
    }.toolbar  {
        SessionListToolbar()
    }
}
