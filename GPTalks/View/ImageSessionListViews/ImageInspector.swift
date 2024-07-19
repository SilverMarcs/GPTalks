//
//  ImageInspector.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData

struct ImageInspector: View {
    @Bindable var session: ImageSession
    @Binding var showInspector: Bool
    
    @Query var providers: [Provider]
    
    var body: some View {
        Form {
            ProviderPicker(provider: $session.config.provider, providers: providers) { provider in
                print(provider.name)
            }
            
            ModelPicker(model: $session.config.model, models: session.config.provider.imageModels)
            
            
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showInspector.toggle()
                } label: {
                    Label("Inspector", systemImage: "sidebar.right")
                }
            }
        }
    }
}

//#Preview {
//    ImageInspector()
//}
