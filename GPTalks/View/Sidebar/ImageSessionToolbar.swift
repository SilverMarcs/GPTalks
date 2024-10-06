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
    
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)])
    var providers: [Provider]
//    var providers: [Provider]
    
    var body: some ToolbarContent {
        SessionToolbar(
            providers: providers,
            addItemAction: { provider in
                sessionVM.addImageSession(modelContext: modelContext, provider: provider)
            },
            getDefaultProvider: { providers in
                ProviderManager.shared.getImageProvider(providers: providers.filter { $0.supportsImage })
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
