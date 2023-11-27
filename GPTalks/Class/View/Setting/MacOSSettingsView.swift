//
//  MacOSSettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

// #if os(macOS)

import SwiftUI

#if os(macOS)
struct MacOSSettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .frame(minHeight: 200)
            DefaultConfigView()
                .tabItem {
                    Label("Default", systemImage: "cpu")
                }
                .frame(minHeight: 300)
            ProviderSettingsView()
                .tabItem {
                    Label("Providers", systemImage: "brain.head.profile")
                }
                .frame(minHeight: 400)
        }
        .frame(width: 650)
    }
}

struct GeneralSettingsView: View {
    @StateObject var configuration = AppConfiguration.shared

    var body: some View {
        ScrollView {
            Form {
                Picker("Markdown Enabled", selection: configuration.$isMarkdownEnabled) {
                    Text("True").tag(true)
                    Text("False").tag(false)
                }
                .pickerStyle(.radioGroup)
                
                Picker("Preferred Provider", selection: configuration.$preferredChatService) {
                    ForEach(Provider.allCases, id: \.self) { provider in
                        Text(provider.name)
                    }
                }
                .pickerStyle(.radioGroup)
            }
        }
        .padding()
    }
}

struct ProviderSettingsView: View {
    @ObservedObject var configuration = AppConfiguration.shared
    @State var selection: Provider = .openai

    var body: some View {
        NavigationView {
            List(Provider.allCases, id: \.self, selection: $selection) { provider in
                NavigationLink(
                    destination: provider.destination,
                    label: { provider.label }
                )
            }
        }
    }
}
#endif
