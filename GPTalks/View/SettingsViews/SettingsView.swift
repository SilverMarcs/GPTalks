//
//  SettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(ChatSessionVM.self) private var sessionVM
    @Environment(\.dismiss) var dismiss
    
    #if os(macOS)
    @State private var selectedSidebarItem: SidebarItem? = .general
    #else
    @State private var selectedSidebarItem: SidebarItem?
    #endif
    
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic

    @Query var providerDefaults: [ProviderDefaults]
    
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
            #if !os(visionOS)
            .navigationTitle("Settings")
            #endif
            .toolbar(removing: .sidebarToggle)
            .toolbar{
                Spacer()
                #if !os(macOS)
                    DismissButton()
                #endif
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
                    QuickPanelSettings(providerDefaults: providerDefaults.first!)
                case .tools:
                    ToolSettings(providerDefaults: providerDefaults.first!)
                case .parameters:
                    ParameterSettings()
                case .image:
                    ImageSettings(providerDefaults: providerDefaults.first!)
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
                    DispatchQueue.main.async {
                        columnVisibility = .all
                    }
                }
            }
        }
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
