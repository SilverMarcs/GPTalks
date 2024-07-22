//
//  ImageGenerationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts

struct ImageGenerationList: View {
    @Bindable var session: ImageSession
    
    @Query var providers: [Provider]
    
    @State var prevCount: Int = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 35) {
                    ForEach(session.imageGenerations, id: \.self) { generation in
                        ImageGenerationView(generation: generation)
                    }
                    
                    Color.clear
                        .id(String.bottomID)
                }
                .safeAreaPadding()
            }
            .toolbar {
                ImageGenerationListToolbar(session: session)
            }
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: session.imageGenerations.count) {
                if session.imageGenerations.count > prevCount {
                    scrollToBottom(proxy: proxy, delay: 0.1)
                } else {
                    prevCount = session.imageGenerations.count
                }
            }
            .scrollContentBackground(.visible)
            .navigationTitle("Image Generation")
            .safeAreaInset(edge: .bottom) {
                ImageInputView(session: session)
            }
#if !os(macOS)
            .toolbarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)) { _ in
                scrollToBottom(proxy: proxy)
            }
#endif
        }
    }
}


#Preview {
    ImageGenerationList(session: ImageSession(config: ImageConfig()))
}
