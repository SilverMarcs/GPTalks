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
    @State var showInspector = false
    
    @Query var providers: [Provider]
    
    var body: some View {
        List {
            ForEach(session.imageGenerations, id: \.self) { generation in
                ImageGenerationView(generation: generation)
            }
        }
        .inspector(isPresented: $showInspector) {
            ImageInspector(session: session, showInspector: $showInspector)
        }
        .safeAreaInset(edge: .bottom) {
            TextField("Prompt", text: $session.prompt)
                .textFieldStyle(.roundedBorder)
                .padding()
            Button("Generate") {
                print("sending")
                Task {
                    await session.send()
                }
            }
        }
    }
}


//#Preview {
//    ImageGenerationList()
//}
