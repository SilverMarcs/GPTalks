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
    var body: some View {
        NavigationSplitView {
            SessionListSidebar()
            #if os(macOS)
                .navigationSplitViewColumnWidth(min: 240, ideal: 250, max: 300)
            #endif
        } detail: {
            ConversationListDetail()
        }
        #if os(macOS)
        .frame(minWidth: 900, minHeight: 700)
        #endif
    }
    

}

#Preview {
    ContentView()
        .modelContainer(for: Session.self, inMemory: true)
        .environment(SessionVM())
}
