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

    enum Item: String, CaseIterable, Identifiable, Hashable {
        case openAI
        case openRouter
        case naga
//        case custom2
//        case summaries

        var id: String { rawValue }

        @ViewBuilder
        var destination: some View {
            @ObservedObject var configuration = AppConfiguration.shared

            switch self {
            case .openAI:
                ServiceSettingsView(
                    model: configuration.$OAImodel,
                    apiKey: configuration.$OAIkey,
                    models: Provider.openai.models,
                    navigationTitle: "OpenAI"
                )
            case .openRouter:
                ServiceSettingsView(
                    model: configuration.$ORmodel,
                    apiKey: configuration.$ORkey,
                    models: Provider.openrouter.models,
                    navigationTitle: "OpenRouter"
                )
            case .naga:
                ServiceSettingsView(
                    model: configuration.$Nmodel,
                    apiKey: configuration.$Nkey,
                    models: Provider.naga.models,
                    navigationTitle: "NagaAI"
                )
//            case .custom2:
//                Custom2SettingsView()
//            case .summaries:
//                SummarySettingsView()
            }
        }

        var label: some View {
            HStack {
                Image(self.rawValue.lowercased())
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(10)
                Text(rawValue.capitalizingFirstLetter())
            }
        }
    }

    @State var selection: Item? = .openAI

    var body: some View {
        NavigationView {
            List(Item.allCases, selection: $selection) { item in
                NavigationLink(
                    destination: item.destination,
                    label: { item.label }
                )
            }
        }
    }
}
