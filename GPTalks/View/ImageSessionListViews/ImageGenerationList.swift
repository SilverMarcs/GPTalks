//
//  ImageGenerationList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData

struct ImageGenerationList: View {
    @Environment(ImageSessionVM.self) var imageVM
    @Bindable var session: ImageSession
    @State private var showingInspector: Bool = false
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(session.imageGenerations, id: \.self) { generation in
                    ImageGenerationView(generation: generation)
                }
                .listRowSeparator(.hidden)
                
                Color.clear
                    .id(String.bottomID)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .onChange(of: imageVM.selections) {
                session.proxy = proxy
                scrollToBottom(proxy: proxy)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ImageInputView(session: session)
            }
            #if os(macOS)
            .navigationTitle(session.title)
            .toolbar {
                ImageGenerationListToolbar()
            }
            #else
            #if !os(visionOS)
            .scrollDismissesKeyboard(.immediately)
            #endif
            .navigationTitle(session.config.model.name)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                showInspector
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)) { _ in
                scrollToBottom(proxy: proxy)
            }
            #endif
            #if !os(macOS)
            .sheet(isPresented: $showingInspector) {
                ImageInspector(session: session, showingInspector: $showingInspector)
            }
            #endif
        }
    }
    
//    #if !os(macOS)
    private var showInspector: some ToolbarContent {
        ToolbarItem {
            Button {
                showingInspector.toggle()
            } label: {
                Label("Show Inspector", systemImage: "info.circle")
            }
        }
    }
//    #endif
}


#Preview {
    ImageGenerationList(session: .mockImageSession)
}
