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
            MacOSAppearanceView()
                .frame(width: 650, height: 400)
                .tabItem {
                    Label("Appearance", systemImage: "wand.and.stars")
                }
        
            MacOSDefaultParameters()
                .frame(width: 650, height: 300)
                .tabItem {
                    Label("Parameters", systemImage: "slider.horizontal.3")
                }
        
            ProviderSettingsView()
                .frame(width: 650, height: 370)
                .tabItem {
                    Label("Providers", systemImage: "brain.head.profile")
                }
            
            ToolsView()
                .frame(width: 650, height: 300)
                .tabItem {
                    Label("Plugins", systemImage: "wrench")
                }
        }
    }
}

struct ToolsView: View {
    @State var selection: ChatTool = .urlScrape
    
    var body: some View {
        NavigationView {
            List(ChatTool.allCases, id: \.self, selection: $selection) { tool in
                NavigationLink(
                    destination: tool.destination,
                    label: { tool.settingsLabel }
                )
            }
            .listStyle(.inset)
        }
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

struct MacOSAppearanceView: View {
    var body: some View {
        GroupBox("Config") {
            LabeledPicker(title: "Markdown Enabled", width: 300, picker: MarkdownEnabler(isPicker: true))
                .padding(10)
                
            Divider()
                
            LabeledPicker(title: "Alternate Markdown", width: 300, picker: AlternateMarkdownEnabler(isPicker: true))
                .padding(10)
                
            Divider()
            
            LabeledPicker(title: "AutoGen Title", width: 300, picker: AutoGenTitleEnabler(isPicker: true))
                .padding(10)
            
            Divider()
                
            LabeledPicker(title: "Preferred Chat Provider", width: 300, picker: PreferredChatProvider())
                .padding(10)
                
            Divider()
                
            LabeledPicker(title: "Preferred Image Provider", width: 300, picker: PreferredImageProvider())
                .padding(10)
        }
        .padding(30)
    }
}

struct MacOSDefaultParameters: View {
    var body: some View {
        VStack(spacing: 20) {
            GroupBox(label: Text("Default Parameters")) {
                HStack {
                    Text("Temperature")
                    Spacer()
                    DefaultTempSlider()
                        .frame(width: widthValue)
                }
                .padding(paddingValue)

                Divider()

                HStack {
                    Text("System prompt")
                    Spacer()
                    DefaultSystemPrompt()
                        .textFieldStyle(.roundedBorder)
                        .frame(width: widthValue)
                }
                .padding(paddingValue)
            }
        
            Spacer()
        }
        .padding(30)
    }

    var paddingValue: CGFloat {
        10
    }

    var widthValue: CGFloat {
        300
    }
}
#endif
