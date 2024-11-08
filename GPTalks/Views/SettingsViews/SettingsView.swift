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
    @State private var selectedSettingsSidebar: SettingsSidebar? = .general
    #else
    @State private var selectedSettingsSidebar: SettingsSidebar?
    #endif
    
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic

    @Query var providerDefaults: [ProviderDefaults]
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedSettingsSidebar) {
                Label("General", systemImage: "gear")
                    .tag(SettingsSidebar.general)
                
                Label("Appearance", systemImage: "paintbrush")
                    .tag(SettingsSidebar.appearance)
                
                #if os(macOS)
                Label("Quick Panel", systemImage: "bolt.fill")
                    .tag(SettingsSidebar.quickPanel)
                #endif
                
                Label("Plugins", systemImage: "hammer")
                    .tag(SettingsSidebar.tools)
                
                Label("Parameters", systemImage: "slider.horizontal.3")
                    .tag(SettingsSidebar.parameters)
                
                Label("Image Gen", systemImage: "photo")
                    .tag(SettingsSidebar.image)
                
                Label("Providers", systemImage: "cpu")
                    .tag(SettingsSidebar.providers)
                
                Label("Guides", systemImage: "book")
                    .tag(SettingsSidebar.guides)
                
                Label("About", systemImage: "info.circle")
                    .tag(SettingsSidebar.about)
                         
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
                switch selectedSettingsSidebar {
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
}

#Preview {
    SettingsView()
        .modelContainer(for: ProviderDefaults.self, inMemory: true)
        .environment(ChatVM.mockSessionVM)
}
