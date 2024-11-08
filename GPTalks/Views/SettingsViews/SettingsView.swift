//
//  SettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(ChatVM.self) private var sessionVM
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
                
                Label("Guides", systemImage: "book")
                    .tag(SidebarItem.guides)
                
                Label("About", systemImage: "info.circle")
                    .tag(SidebarItem.about)
                         
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
            NavigationStack {
                switch selectedSidebarItem {
                case .general:
                    GeneralSettings()
                case .appearance:
                    AppearanceSettings()
                case .quickPanel:
                    QuickPanelSettings(providerDefaults: providerDefaults.first!)
                case .tools:
                    PluginSettings(providerDefaults: providerDefaults.first!)
                case .parameters:
                    ParameterSettings()
                case .image:
                    ImageSettings(providerDefaults: providerDefaults.first!)
                case .providers:
                    ProviderList()
                case .guides:
                    GuidesSettings()
                case .about:
                    AboutSettings()
                default:
                    EmptyView()
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
        case quickPanel
        case tools
        case parameters
        case image
        case providers
        case guides
        case about
    }

}

#Preview {
    SettingsView()
        .modelContainer(for: ProviderDefaults.self, inMemory: true)
        .environment(ChatVM.mockSessionVM)
}
