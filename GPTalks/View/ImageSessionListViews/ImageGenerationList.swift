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
    @State private var showingInspector: Bool = false
    
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
                .padding()
            }
            .onAppear {
                session.proxy = proxy
                scrollToBottom(proxy: proxy)
            }
            .scrollContentBackground(.visible)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ImageInputView(session: session)
            }
#if os(macOS)
            .navigationTitle(session.title)
            .toolbar {
                ImageGenerationListToolbar(session: session)
            }
#else
            #if !os(visionOS)
            .scrollDismissesKeyboard(.immediately)
            .inspector(isPresented: $showingInspector) {
                InspectorView(showingInspector: $showingInspector)
            }
            #else
            .sheet(isPresented: $showingInspector) {
                InspectorView(showingInspector: $showingInspector)
            }
            #endif
            .navigationTitle(session.config.model.name)
            .onTapGesture {
                showingInspector = false
            }
            .toolbar {
                showInspector
            }
            .toolbarTitleDisplayMode(.inline)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)) { _ in
                scrollToBottom(proxy: proxy)
            }
#endif
        }
    }
    
    #if !os(macOS)
    private var showInspector: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingInspector.toggle()
            } label: {
                Label("Show Inspector", systemImage: "info.circle")
            }
        }
    }
    #endif
}


#Preview {
    ImageGenerationList(session: ImageSession(config: ImageConfig()))
}
