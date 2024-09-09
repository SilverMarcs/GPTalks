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
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
    
    var body: some View {
        NavigationSplitView {
            SessionListSidebar(providers: providers)
#if targetEnvironment(macCatalyst)
    .toolbar(.hidden, for: .navigationBar)
#endif
            #if os(macOS) || targetEnvironment(macCatalyst)
                .navigationSplitViewColumnWidth(min: 240, ideal: 250, max: 300)
            #endif
        } detail: {
            ConversationListDetail(providers: providers)
#if targetEnvironment(macCatalyst)
    .toolbar(.hidden, for: .navigationBar)
#endif
        }
        #if os(macOS) || targetEnvironment(macCatalyst)
        .frame(minWidth: 900, minHeight: 700)
        #endif
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Session.self, inMemory: true)
        .environment(SessionVM())
}
