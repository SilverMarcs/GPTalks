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
            PromptSettingsView()
                .tabItem {
                    Label("Prompt", systemImage: "text.book.closed")
                }
        }
        .frame(minWidth: 700, minHeight: 400)
    }
}


struct GeneralSettingsView: View {
    
    @StateObject var configuration = AppConfiguration.shared
    
    var body: some View {
            VStack(alignment: .center, spacing: 20) {
                Toggle("Markdown Enabled", isOn: configuration.$isMarkdownEnabled)
                
//                Toggle("Auto Generate Chat Title", isOn: configuration.$isAutoGenerateTitle)

                HStack {
                    Text("Preferred AI Provider")
                    
                    Spacer()
                    
                    Picker(selection: configuration.$preferredChatService) {
                        ForEach(AIProvider.allCases, id: \.self) {
                            Text($0.rawValue.capitalizingFirstLetter())
                        }
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
        case pAI
        case summaries
        
        var id: String { rawValue }
        
        @ViewBuilder
        var destination: some View {
            switch self {
            case .openAI:
                OpenAISettingsView()
            case .openRouter:
                OpenRouterSettingsView()
            case .pAI:
                PAISettingsView()
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
            List(selection: $selection) {
                ForEach(Item.allCases) { item in
                    NavigationLink(
                        destination: item.destination,
                        tag: item,
                        selection: $selection,
                        label: {
                            item.label
                        }
                    )
                }
            }
            .listStyle(.sidebar)
        }
    }
}

struct PromptSettingsView: View {
    
    enum Item: String, CaseIterable, Identifiable, Hashable {
        case syncPrompts = "syncPrompts"
        case customPrompts = "customPrompts"
        
        var id: String { rawValue }
        
        var destination: some View {
            makeDestination()
        }
        
        @ViewBuilder
        private func makeDestination() -> some View {
            switch self {
            case .syncPrompts:
                PromptsListView()
                    .padding()
            case .customPrompts:
                CustomPromptsView()
            }
        }
        
        var label: some View {
            switch self {
            case .syncPrompts:
                return HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Sync Prompts")
                }
            case .customPrompts:
                return HStack {
                    Image(systemName: "person")
                    Text("Custom Prompts")
                }
            }
        }
    }
    
    @State var selection: Item? = .syncPrompts
    
    var body: some View {
        NavigationView {
            List(selection: $selection) {
                ForEach(Item.allCases) { item in
                    NavigationLink(
                        destination: item.destination,
                        tag: item,
                        selection: $selection,
                        label: {
                            item.label
                        }
                    )
                }
            }
            .listStyle(.sidebar)
        }
    }
    
}

struct MacOSSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MacOSSettingsView()
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
