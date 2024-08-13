//
//  ImageSessionToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/13/24.
//

import SwiftUI
import SwiftData

struct ImageSessionToolbar: ToolbarContent {
    #if !os(macOS)
    @Environment(\.editMode) var editMode
    #endif
    @Environment(SessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    
    @ObservedObject var config = AppConfig.shared
    
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)], animation: .default)
    var providers: [Provider]
    @Query var imageSessions: [ImageSession]
    
    var body: some ToolbarContent {
#if !os(macOS)
        iosParts
#endif
        ToolbarItem {
            Spacer()
        }
        
        ToolbarItem(placement: .automatic) {
            Menu {
                ForEach(providers) { provider in
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
                }
            }
            .keyboardShortcut("n", modifiers: [.command])
            .menuIndicator(.hidden)
        }
    }

    private func addItem(provider: Provider) {
        let newItem = ImageSession(config: ImageConfig(provider: provider, model: provider.imageModel))
        
        withAnimation {
            for session in imageSessions {
                session.order += 1
            }
            
            newItem.order = 0
            modelContext.insert(newItem)
            sessionVM.imageSelections = [newItem]
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
                            for session in sessionVM.selections {
                                session.isStarred.toggle()
                            }
                        } label: {
                            Label("Toggle Starred", systemImage: "star")
                        }
                        
                        Section {
                            Button {
                                sessionVM.imageSelections = Set(imageSessions)
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
    }
    #endif
}

#Preview {
    VStack {
        Text("Hi")
    }.toolbar  {
//        SessionListToolbar()
    }
}
