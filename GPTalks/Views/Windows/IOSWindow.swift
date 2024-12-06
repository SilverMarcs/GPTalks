//
//  IOSWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 28/09/2024.
//

import SwiftUI

struct IOSWindow: Scene {
    @Environment(SettingsVM.self) private var settingsVM
    @Environment(ChatVM.self) private var chatVM
    @Environment(ImageVM.self) private var imageVM
    
    @ObservedObject var config = AppConfig.shared
    
    var body: some Scene {
        @Bindable var chatVM = chatVM
        @Bindable var settingsVM = settingsVM
        
        WindowGroup("Chats", id: "chats") {
            NavigationSplitView {
                Group {
                    switch settingsVM.listState {
                    case .chats:
                        ChatList(status: chatVM.statusFilter, searchText: chatVM.searchText, searchTokens: [])
                            .searchable(text: $chatVM.searchText)
                    case .images:
                        ImageList()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button(action: { settingsVM.showSettings.toggle() }) {
                                Label("Settings", systemImage: "gear")
                            }
                        } label: {
                            Label("More", systemImage: "ellipsis.circle")
                                .labelStyle(.titleOnly)
                        }
                        .sheet(isPresented: $settingsVM.showSettings) {
                            SettingsView()
                        }
                    }
                }
            } detail: {
                switch settingsVM.listState {
                case .chats:
                    if let chat = chatVM.activeChat {
                        ChatDetail(chat: chat)
                            .id(chat.id)
                    } else {
                        Text("^[\(chatVM.selections.count) Chat](inflect: true) Selected")
                    }
                case .images:
                    if let imageSession = imageVM.activeImageSession {
                        ImageDetail(session: imageSession)
                    } else {
                        Text("^[\(imageVM.selections.count) Image Session](inflect: true) Selected")
                    }
                }
            }
            .sheet(isPresented: .constant(!config.hasCompletedOnboarding)) {
                OnboardingView()
            }
        }
    }
}
