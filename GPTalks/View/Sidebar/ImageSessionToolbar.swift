//
//  ImageSessionToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/13/24.
//

import SwiftUI
import SwiftData

struct ImageSessionToolbar: ToolbarContent {
    @Environment(ImageSessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    
    @Query(filter: #Predicate { $0.isEnabled && $0.supportsImage }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
    
    var body: some ToolbarContent {
        SessionToolbar(
            providers: providers,
            addItemAction: { provider in
                sessionVM.addImageSession(modelContext: modelContext, provider: provider)
            },
            getDefaultProvider: { providers in
                let fetchDefaults = FetchDescriptor<ProviderDefaults>()
                let defaults = try! modelContext.fetch(fetchDefaults)
                
                let defaultProvider = defaults.first!.imageProvider
                return defaultProvider
            }
        )
    }
}

#Preview {
    VStack {
        Text("Hi")
    }.toolbar  {
        ImageSessionToolbar()
    }
}
