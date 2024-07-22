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
        TabView {
            Group {
                GeneralSettings()
                    .tabItem {
                        Label("General", systemImage: "gear")
                    }

                #if os(macOS)
                QuickPanelSettings()
                    .tabItem {
                        Label("Quick Panel", systemImage: "bolt.fill")
                    }
                #endif
                
                ParameterSettings()
                    .tabItem {
                        Label("Parameters", systemImage: "slider.horizontal.3")
                    }

                ProviderList()
                    .tabItem {
                        Label("Providers", systemImage: "cpu")
                    }
            }
            #if os(macOS)
//            .padding(.horizontal, 80)
            .frame(width: 700, height: 410)
            #endif
        }
    }
}

#Preview {
    SettingsView()
}
