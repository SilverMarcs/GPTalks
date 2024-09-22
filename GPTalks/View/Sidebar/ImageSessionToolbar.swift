//
//  ImageSessionToolbar.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/13/24.
//

import SwiftUI
import SwiftData

struct ImageSessionToolbar: ToolbarContent {
    @Environment(SessionVM.self) var sessionVM
    @Environment(\.modelContext) var modelContext
    
    var providers: [Provider]
    
    var body: some ToolbarContent {
        SessionToolbar(
            providers: providers,
            addItemAction: { provider in
                sessionVM.addImageSession(modelContext: modelContext, provider: provider)
            },
            getDefaultProvider: { providers in
                ProviderManager.shared.getImageProvider(providers: providers.filter { $0.supportsImage })
            },
            selectionType: .images
        )
    }
}

#Preview {
    VStack {
        Text("Hi")
    }.toolbar  {
        ImageSessionToolbar(providers: [])
    }
}
