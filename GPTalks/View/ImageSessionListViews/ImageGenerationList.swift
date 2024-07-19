//
//  ImageGenerationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData

struct ImageGenerationList: View {
    @Bindable var session: ImageSession
    
    @Query var providers: [Provider]
    
    var body: some View {
        List {
            ForEach(session.imageGenerations, id: \.self) { generation in
                ImageGenerationView(generation: generation)
            }
        }
        .navigationTitle("Image Generation")
        .safeAreaInset(edge: .bottom) {
            ImageInputView(session: session)
        }
    }
}


//#Preview {
//    ImageGenerationList()
//}
