//
//  SettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
#if os(iOS)
        TabView {
            GeneralSettings()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            ParameterSettings()
                .tabItem {
                    Label("Parameters", systemImage: "slider.horizontal.3")
                }
            
            ProviderList()
                .tabItem {
                    Label("Providers", systemImage: "cpu")
                }
        }
#else
        TabView {
            Group {
                GeneralSettings()
                    .tabItem {
                        Label("General", systemImage: "gear")
                    }

                QuickPanelSettings()
                    .tabItem {
                        Label("Quick Panel", systemImage: "bolt.fill")
                    }
                
                ParameterSettings()
                    .tabItem {
                        Label("Parameters", systemImage: "slider.horizontal.3")
                    }

                ProviderList()
                    .padding(.horizontal, -80)
                    .tabItem {
                        Label("Providers", systemImage: "cpu")
                    }
            }
            .padding(.horizontal, 80)
            .frame(width: 700, height: 410)
        }
#endif
    }
}

#Preview {
    SettingsView()
}
