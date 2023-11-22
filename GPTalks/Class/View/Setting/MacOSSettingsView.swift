//
//  MacOSSettingsView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/4/3.
//

// #if os(macOS)

import SwiftUI

struct MacOSSettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            DefaultConfigView()
                .tabItem {
                    Label("Default", systemImage: "cpu")
                }
            ProviderSettingsView()
                .tabItem {
                    Label("Providers", systemImage: "brain.head.profile")
                }
        }
        .frame(minWidth: 700, minHeight: 300)
    }
}

struct GeneralSettingsView: View {
    @StateObject var configuration = AppConfiguration.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Toggle("Markdown Enabled", isOn: configuration.$isMarkdownEnabled)

            Picker("Preferred AI Provider", selection: configuration.$preferredChatService) {
                ForEach(Provider.allCases, id: \.self) {
                    Text($0.rawValue.capitalizingFirstLetter())
                }
            }
        }
        .frame(width: 300)
    }
}

struct ProviderSettingsView: View {
    @ObservedObject var configuration = AppConfiguration.shared
    @State var selection: Provider? = .openai

    var body: some View {
        NavigationView {
            List(Provider.allCases, selection: $selection) { provider in
                NavigationLink(
                    destination: provider.destination,
                    label: { provider.label }
                )
            }
        }
    }
}
