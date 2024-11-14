//
//  ImageDetail.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI
import SwiftData

struct ImageDetail: View {
    @Environment(ImageVM.self) var imageVM
    @Bindable var session: ImageSession
    @State private var showingInspector: Bool = false
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(session.imageGenerations.sorted(by: { $0.date < $1.date })) { generation in
                    GenerationView(generation: generation)
                }
                .listRowSeparator(.hidden)
                
                Color.clear
                    .id(String.bottomID)
                    .listRowSeparator(.hidden)
            }
            .task {
                session.proxy = proxy
                scrollToBottom(proxy: proxy)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ImageInputView(session: session)
            }
            #if os(macOS)
            .navigationTitle(session.title)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: {} ) {
                        Image(systemName: "slider.vertical.3")
                    }
                    .menuIndicator(.hidden)
                }
            }
            #else
            #if !os(visionOS)
            .scrollDismissesKeyboard(.immediately)
            #endif
            .listStyle(.plain)
            .navigationTitle(session.config.model.name)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        showingInspector.toggle()
                    } label: {
                        Label("Show Inspector", systemImage: "info.circle")
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)) { _ in
                scrollToBottom(proxy: proxy)
            }
            .sheet(isPresented: $showingInspector) {
                ImageInspector(session: session, showingInspector: $showingInspector)
            }
            #endif
        }
    }
}


#Preview {
    ImageDetail(session: .mockImageSession)
}
