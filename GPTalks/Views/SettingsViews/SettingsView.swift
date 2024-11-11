//
//  SettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(SettingsVM.self) private var settingsVM
    
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic

    @Query var providerDefaults: [ProviderDefaults]
    
    var body: some View {
        @Bindable var settingsVM = settingsVM
        
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $settingsVM.settingsTab) {
                Label("General", systemImage: "gear")
                    .tag(SettingsTab.general)
                
                Label("Appearance", systemImage: "paintbrush")
                    .tag(SettingsTab.appearance)
                
                #if os(macOS)
                Label("Quick Panel", systemImage: "bolt.fill")
                    .tag(SettingsTab.quickPanel)
                #endif
                
                Label("Plugins", systemImage: "hammer")
                    .tag(SettingsTab.tools)
                
                Label("Parameters", systemImage: "slider.horizontal.3")
                    .tag(SettingsTab.parameters)
                
                Label("Image Gen", systemImage: "photo")
                    .tag(SettingsTab.image)
                
                Label("Providers", systemImage: "cpu")
                    .tag(SettingsTab.providers)
                
                Label("Advanced", systemImage: "gearshape.2")
                    .tag(SettingsTab.advanced)
                
                Label("Guides", systemImage: "book")
                    .tag(SettingsTab.guides)
                
                Label("About", systemImage: "info.circle")
                    .tag(SettingsTab.about)
                         
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
                switch settingsVM.settingsTab {
                case .general:
                    GeneralSettings()
                case .appearance:
                    AppearanceSettings()
                #if os(macOS)
                case .quickPanel:
                    QuickPanelSettings(providerDefaults: providerDefaults.first!)
                #endif
                case .tools:
                    PluginSettings(providerDefaults: providerDefaults.first!)
                case .parameters:
                    ParameterSettings()
                case .image:
                    ImageSettings(providerDefaults: providerDefaults.first!)
                case .providers:
                    ProviderList()
                case .advanced:
                    AdvancedSettings()
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
}
