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
            ProviderSettingsView()
                .tabItem {
                    Label("Providers", systemImage: "brain.head.profile")
                }
        }
        .frame(minWidth: 700, minHeight: 400)
    }
}

struct GeneralSettingsView: View {
    @StateObject var configuration = AppConfiguration.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Toggle("Markdown Enabled", isOn: configuration.$isMarkdownEnabled)

            Picker("Preferred AI Provider", selection: configuration.$preferredChatService) {
                ForEach(AIProvider.allCases, id: \.self) {
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
        case custom
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
                    temperature: configuration.$OAItemperature,
                    contextLength: configuration.$OAIcontextLength,
                    systemPrompt: configuration.$OAIsystemPrompt,
                    apiKey: configuration.$OAIkey,
                    models: AIProvider.openai.models,
                    navigationTitle: "OpenAI"
                )
            case .openRouter:
                ServiceSettingsView(
                    model: configuration.$ORmodel,
                    temperature: configuration.$ORtemperature,
                    contextLength: configuration.$ORcontextLength,
                    systemPrompt: configuration.$ORsystemPrompt,
                    apiKey: configuration.$Ckey,
                    models: AIProvider.openrouter.models,
                    navigationTitle: "OpenRouter"
                )
            case .custom:
                ServiceSettingsView(
                    model: configuration.$Cmodel,
                    temperature: configuration.$Ctemperature,
                    contextLength: configuration.$CcontextLength,
                    systemPrompt: configuration.$CsystemPrompt,
                    apiKey: configuration.$Ckey,
                    models: AIProvider.custom.models,
                    navigationTitle: "Custom"
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

// #endif

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }
}
