//
//  SettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    #if os(macOS)
    @State private var selectedSidebarItem: SidebarItem? = .general
    #else
    @State private var selectedSidebarItem: SidebarItem?
    #endif
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSidebarItem) {
                Label("General", systemImage: "gear")
                    .tag(SidebarItem.general)
                
                #if os(macOS)
                Label("Quick Panel", systemImage: "bolt.fill")
                    .tag(SidebarItem.quickPanel)
                #endif
                
                Label("Parameters", systemImage: "slider.horizontal.3")
                    .tag(SidebarItem.parameters)
                
                Label("Providers", systemImage: "cpu")
                    .tag(SidebarItem.providers)
                
                Label("Backup", systemImage: "opticaldiscdrive")
                    .tag(SidebarItem.backup)
            }
            .navigationTitle("Settings")
            .toolbar(removing: .sidebarToggle)
            .toolbar{
                Spacer()
                #if !os(macOS)
                DismissButton()
                #endif
            }
        } detail: {
            switch selectedSidebarItem {
            case .general:
                GeneralSettings()
            case .quickPanel:
                #if os(macOS)
                QuickPanelSettings()
                #else
                EmptyView()
                #endif
            case .parameters:
                ParameterSettings()
            case .providers:
                ProviderList()
            case .backup:
                BackupSettings()
            case .none:
                Text("Select an option from the sidebar")
            }
        }
    }
}

enum SidebarItem {
    case general
    case quickPanel
    case parameters
    case providers
    case backup
}


#Preview {
    SettingsView()
}
