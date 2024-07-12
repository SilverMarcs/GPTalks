//
//  SettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettings()
                .platformPadding()
                .frame(minHeight: 200)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            #if os(macOS)
            QuickPanelSettings()
                .platformPadding()
                .frame(minHeight: 140)
                .tabItem {
                    Label("Quick Panel", systemImage: "bolt.fill")
                }
            #endif
            
            ParameterSettings()
                .platformPadding()
                .frame(minHeight: 300)
                .tabItem {
                    Label("Parameters", systemImage: "slider.horizontal.3")
                }
            
            ProviderList()
            #if os(macOS)
            .frame(maxWidth: 700, minHeight: 400)
            #endif
                .tabItem {
                    Label("Providers", systemImage: "cpu")
                }
        }

    }
}

#Preview {
    SettingsView()
}

struct PlatformPadding: ViewModifier {
    func body(content: Content) -> some View {
#if os(macOS)
        content
            .padding(.horizontal, 80)
            .frame(width: 700)
#else
        content
#endif
    }
}

extension View {
    func platformPadding() -> some View {
        self.modifier(PlatformPadding())
    }
}
