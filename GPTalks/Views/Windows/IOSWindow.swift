//
//  IOSWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 28/09/2024.
//

import SwiftUI
import SwiftData

#if !os(macOS)
struct IOSWindow: Scene {
    @Environment(SettingsVM.self) private var listStateVM
    @Environment(ChatVM.self) private var chatVM
    @Environment(ImageVM.self) private var imageVM
    
    @State private var showSettings = false
    
    var body: some Scene {
        @Bindable var chatVM = chatVM
        
        WindowGroup("Chats", id: "chats") {
            NavigationSplitView {
                if !chatVM.searchResults.isEmpty {
                    ChatOrSearchView()
                } else {
                    Group {
                        switch listStateVM.listState {
                        case .chats:
                            ChatList(status: chatVM.statusFilter, searchText: chatVM.searchText)
                        case .images:
                            ImageList()
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Menu {
                                Button(action: { showSettings.toggle() }) {
                                    Label("Settings", systemImage: "gear")
                                }
                                
//                                Picker("Chat Status", selection: $chatVM.statusFilter) {
//                                    ForEach([ChatStatus.normal, .starred, .archived]) { status in
//                                        Label(status.name, systemImage: status.systemImageName)
//                                            .tag(status)
//                                    }
//                                }
//                                #if os(macOS)
//                                .labelsHidden()
//                                #endif
//                                .pickerStyle(.inline)
                                
                            } label: {
                                Label("More", systemImage: "ellipsis.circle")
                                    .labelStyle(.titleOnly)
                            }
                            .sheet(isPresented: $showSettings) {
                                SettingsView()
                            }
                        }
                    }
                }
            } detail: {
                switch listStateVM.listState {
                case .chats:
                    if let chat = chatVM.activeChat {
                        ChatDetail(chat: chat)
                            .id(chat.id)
                    } else {
                        Text("^[\(chatVM.selections.count) Chat Session](inflect: true) Selected")
                    }
                case .images:
                    if let imageSession = imageVM.activeImageSession {
                        ImageDetail(session: imageSession)
                    } else {
                        Text("^[\(imageVM.selections.count) Image Session](inflect: true) Selected")
                    }
                }
            }
        }
    }
}
#endif
