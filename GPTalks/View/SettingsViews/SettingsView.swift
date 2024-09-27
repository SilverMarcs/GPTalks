//
//  SettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
//    @Environment(ChatSessionVM.self) private var sessionVM
//    
//    @State var selections: Set<ChatSession> = []
//    @FocusState private var isFocused: Bool
    
    #if os(macOS)
    @State private var selectedSidebarItem: SidebarItem? = .general
    #else
    @State private var selectedSidebarItem: SidebarItem?
    #endif
    
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedSidebarItem) {
                Label("General", systemImage: "gear")
                    .tag(SidebarItem.general)
                
                Label("Appearance", systemImage: "paintbrush")
                    .tag(SidebarItem.appearance)
                
                Label("Markdown", systemImage: "ellipsis.curlybraces")
                    .tag(SidebarItem.markdown)
                
#if os(macOS)
                Label("Quick Panel", systemImage: "bolt.fill")
                    .tag(SidebarItem.quickPanel)
#endif
                Label("Plugins", systemImage: "hammer")
                    .tag(SidebarItem.tools)
                
                Label("Parameters", systemImage: "slider.horizontal.3")
                    .tag(SidebarItem.parameters)
                
                Label("Image Gen", systemImage: "photo")
                    .tag(SidebarItem.image)
                
                
                Label("Providers", systemImage: "cpu")
                    .tag(SidebarItem.providers)
                
                Label("Backup", systemImage: "opticaldiscdrive")
                    .tag(SidebarItem.backup)
            }
            .navigationTitle("Settings")
            .toolbar(removing: .sidebarToggle)
            .toolbar{
                Spacer()
                if isIOS() || isVisionOS() {
                    DismissButton()
                }
            }
            .navigationSplitViewColumnWidth(min: 190, ideal: 190, max: 190)
        } detail: {
            Group {
                switch selectedSidebarItem {
                case .general:
                    GeneralSettings()
                case .appearance:
                    AppearanceSettings()
                case .markdown:
                    MarkdownSettings()
                case .quickPanel:
                    QuickPanelSettings()
                case .tools:
                    ToolSettings()
                case .parameters:
                    ParameterSettings()
                case .image:
                    ImageSettings()
                case .providers:
                    ProviderList()
                case .backup:
                    BackupSettings()
                case .none:
                    Text("Select an option from the sidebar")
                }
            }
            .scrollContentBackground(.visible)
            .onChange(of: columnVisibility, initial: true) { oldVal, newVal in
                if newVal == .detailOnly {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        columnVisibility = .all
                    }
                }
            }
        }
//        .onAppear {
//            selections = sessionVM.chatSelections
//            sessionVM.chatSelections = []
//            isFocused = true
//        }
//        .onDisappear {
//            sessionVM.chatSelections = selections
//        }
    }
    
    enum SidebarItem {
        case general
        case appearance
        case markdown
        case quickPanel
        case tools
        case parameters
        case image
        case providers
        case backup
    }

}

#Preview {
    SettingsView()
}
