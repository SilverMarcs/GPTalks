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
                .frame(width: 620, height: 150)
                .tabItem {
                    Label("Appearance", systemImage: "wand.and.stars")
                }
        
            MacOSDefaultParameters()
                .frame(width: 620, height: 380)
                .tabItem {
                    Label("Session", systemImage: "slider.horizontal.3")
                }
        
            ProviderSettingsView()
                .frame(width: 620, height: 380)
                .tabItem {
                    Label("Providers", systemImage: "cpu")
                }
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
            .listStyle(.sidebar)
        }
    }
}

struct MacOSAppearanceView: View {
    @ObservedObject var configuration: AppConfiguration = .shared
    
    var body: some View {
        Form {
            Section {
                Toggle("AutoGen Title", isOn: $configuration.isAutoGenerateTitle)
                Toggle("Assistant Message Markdown", isOn: $configuration.isMarkdownEnabled)
            }
        }
        .formStyle(.grouped)
    }
}

struct MacOSDefaultParameters: View {
    @ObservedObject var configuration: AppConfiguration = .shared
    
    var body: some View {
        Form {
            Picker("Preferred Chat Provider", selection: $configuration.preferredChatService) {
                ForEach(Provider.availableProviders, id: \.self) { provider in
                    Text(provider.name)
                }
            }
            Picker("Preferred Image Provider", selection: $configuration.preferredImageService) {
                ForEach(Provider.availableProviders, id: \.self) { provider in
                    Text(provider.name)
                }
            }
            
            Section("Default Parameters") {
                Slider(value: $configuration.temperature, in: 0...2, step: 0.1) {
                    Text(String(format: "%.2f", configuration.temperature))
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("2")
                }
            }
        
            
            Section("System prompt") {
                TextEditor(text: AppConfiguration.shared.$systemPrompt)
                    .font(.system(size: 14))
                    .scrollContentBackground(.hidden)
            }
        }
        .formStyle(.grouped)
    }
}
#endif
