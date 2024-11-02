//
//  ImageSessionToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/13/24.
//

import SwiftUI
import SwiftData

struct ImageSessionToolbar: ToolbarContent {
    @Environment(ImageSessionVM.self) var imageVM
    @Environment(\.modelContext) var modelContext
    
    @ObservedObject var config = AppConfig.shared
    
    @Query(filter: #Predicate<Provider> { $0.isEnabled })
    var providers: [Provider]
    
    var filteredProviders: [Provider] {
        providers.filter { !$0.imageModels.isEmpty }
    }
    
    var body: some ToolbarContent {
        #if !os(macOS)
        iosParts
        #endif
        
        ToolbarItem { Spacer() }
        
        ToolbarItem(placement: .automatic) {
            Menu {
                ForEach(providers) { provider in
                    Button(provider.name) {
                        imageVM.createNewSession(provider: provider)
                    }
                    .keyboardShortcut(.none)
                }
            } label: {
                Label("Add Item", systemImage: "square.and.pencil")
            } primaryAction: {
                imageVM.createNewSession()
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

#Preview {
    VStack {
        Text("Hi")
    }.toolbar  {
        ImageSessionToolbar()
    }
}
