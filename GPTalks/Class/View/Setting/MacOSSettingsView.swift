//
//  MacOSSettingsView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/4/3.
//

#if os(macOS)

import SwiftUI

struct MacOSSettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            ModelSettingsView()
                .tabItem {
                    Label("Services", systemImage: "brain.head.profile")
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


struct ModelSettingsView: View {
    

    enum Item: String, CaseIterable, Identifiable, Hashable {
        case openAI
        case openRouter
        case custom
        case summaries
        
        var id: String { rawValue }
        
        @ViewBuilder
        var destination: some View {
            switch self {
            case .openAI:
                OpenAISettingsView()
            case .openRouter:
                OpenRouterSettingsView()
            case .custom:
                CustomSettingsView()
            case .summaries:
                SummarySettingsView()
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
            List(Item.allCases, selection: $selection) {item in
                NavigationLink(
                    destination: item.destination,
                    label: { item.label }
                )
            }
            .listStyle(.sidebar)
        }
    }
}

#endif


extension String {
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
}
