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
    @Environment(SessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    
    @ObservedObject var config = AppConfig.shared
    
    var providers: [Provider]
    var addItemAction: (Provider) -> Void
    var getDefaultProvider: ([Provider]) -> Provider?
    var selectionType: SessionVM.ListState
    
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
                if editMode?.wrappedValue == .inactive {
                    Button {
                        withAnimation {
                            editMode?.wrappedValue = .active
                            config.truncateList = false
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
                            config.truncateList = true
                        }
                    } label: {
                        Text("Done")
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button {
//                            for session in sessionVM.getSelections(for: selectionType) {
//                                session.isStarred.toggle()
//                            }
                        } label: {
                            Label("Toggle Starred", systemImage: "star")
                        }
                        
                        Section {
                            Button {
//                                sessionVM.selectAll(of: T.self, in: modelContext)
                            } label: {
                                Label("Select All", systemImage: "checkmark.circle")
                            }
                            
                            Button {
//                                sessionVM.deselectAll(for: selectionType)
                            } label: {
                                Label("Deselect All", systemImage: "xmark.circle")
                            }
                        }
                        
                        Button(role: .destructive) {
//                            for session in sessionVM.getSelections(for: selectionType) {
//                                modelContext.delete(session)
//                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Label("Actions", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
    }
    #endif
}
