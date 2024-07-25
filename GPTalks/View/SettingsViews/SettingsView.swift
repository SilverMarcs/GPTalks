//
//  SettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

enum SidebarItem: Hashable {
    case general
    case quickPanel
    case parameters
    case providers
    case providerDetail(Provider)
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    #if os(macOS)
    @State private var selectedSidebarItem: SidebarItem? = .general
    #else
    @State private var selectedSidebarItem: SidebarItem?
    #endif

    @State private var selectedProvider: Provider?

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
                ProviderList(selectedProvider: $selectedProvider, selectedSidebarItem: $selectedSidebarItem)
            case .providerDetail(let provider):
                ProviderDetail(provider: provider, selectedSidebarItem: $selectedSidebarItem)
            case .none:
                Text("Select an option from the sidebar")
            }
        }
        
        
        
//        TabView {
//            Group {
//                GeneralSettings()
//                    .tabItem {
//                        Label("General", systemImage: "gear")
//                    }
//
//                #if os(macOS)
//                QuickPanelSettings()
//                    .tabItem {
//                        Label("Quick Panel", systemImage: "bolt.fill")
//                    }
//                #endif
//                
//                ParameterSettings()
//                    .tabItem {
//                        Label("Parameters", systemImage: "slider.horizontal.3")
//                    }
//
//                ProviderList()
//                    .tabItem {
//                        Label("Providers", systemImage: "cpu")
//                    }
//            }
//            #if os(macOS)
//            .frame(width: 700, height: 410)
//            #endif
//        }
    }
}

#Preview {
    SettingsView()
}
