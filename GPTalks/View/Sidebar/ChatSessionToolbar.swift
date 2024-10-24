//
//  ChatSessionToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/13/24.
//

import SwiftUI
import SwiftData

struct ChatSessionToolbar: ToolbarContent {
    @Environment(ChatSessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
    
    var body: some ToolbarContent {
        SessionToolbar(
            providers: providers,
            addItemAction: { provider in
                sessionVM.createNewSession(provider: provider)
            },
            getDefaultProvider: { providers in
                let fetchDefaults = FetchDescriptor<ProviderDefaults>()
                let defaults = try! modelContext.fetch(fetchDefaults)
                
                let defaultProvider = defaults.first!.defaultProvider
                return defaultProvider
            }
        )
    }
}

#Preview {
    VStack {
        Text("Hi")
    }.toolbar  {
        ChatSessionToolbar()
    }
}
