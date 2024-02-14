//
//  MacOSSettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//
import SwiftUI

#if os(macOS)
struct MacOSSettingsView: View {
    var body: some View {
        TabView {
            DefaultConfigView()
                .tabItem {
                    Label("Default", systemImage: "cpu")
                }
            ProviderSettingsView()
                .tabItem {
                    Label("Providers", systemImage: "brain.head.profile")
                }
        }
        .frame(width: 650, height: 520)
    }
}

struct ProviderSettingsView: View {
    @State var selection: Provider = .openai

    var body: some View {
        NavigationView {
            List(Provider.availableProviders, id: \.self, selection: $selection) { provider in
                NavigationLink(
                    destination: provider.destination,
                    label: { provider.settingsLabel }
                )
            }
            .listStyle(.inset)
        }
    }
}
#endif
