//
//  ContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(SessionVM.self) private var sessionVM
    @Environment(\.modelContext) private var modelContext
    @Query private var providers: [Provider]

    @ObservedObject var providerManager = ProviderManager.shared
    
    var body: some View {
        NavigationSplitView {
            SessionListSidebar()
        } detail: {
            ConversationListDetail()
        }
        .frame(minWidth: 600, minHeight: 400)
        .background(.background)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if providers.isEmpty {
                    let newProvider = Provider.factory(type: .openai)
                    modelContext.insert(newProvider)
                    
                    if providerManager.getDefault(providers: providers) == nil {
                        providerManager.defaultProvider = newProvider.id.uuidString
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Session.self, inMemory: true)
        .environment(SessionVM())
}
