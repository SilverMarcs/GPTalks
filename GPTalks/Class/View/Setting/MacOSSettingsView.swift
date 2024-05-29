//
//  MacOSSettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//
import KeyboardShortcuts
import SwiftUI

#if os(macOS)
struct MacOSSettingsView: View {
    var body: some View {
        TabView {
            MacOSAppearanceView()
                .frame(width: 620, height: 250)
                .tabItem {
                    Label("Appearance", systemImage: "wand.and.stars")
                }
            
            MacOSQuickPanelSettings()
                .frame(width: 620, height: 300)
                .tabItem {
                    Label("Quick Chat", systemImage: "bolt.fill")
                }
        
            MacOSDefaultParameters()
                .frame(width: 620, height: 420)
                .tabItem {
                    Label("Session", systemImage: "slider.horizontal.3")
                }
        
            ProviderSettingsView()
                .frame(width: 620, height: 380)
                .tabItem {
                    Label("Providers", systemImage: "brain.head.profile")
                }
            
            ToolsView()
                .frame(width: 620, height: 250)
                .tabItem {
                    Label("Plugins", systemImage: "wrench")
                }
        }
    }
}

struct ToolsView: View {
    @State var selection: ChatTool = .googleSearch
    
    var body: some View {
        NavigationView {
            List(ChatTool.allCases, id: \.self, selection: $selection) { tool in
                NavigationLink(
                    destination: tool.destination,
                    label: {
                        HStack {
                            Image(systemName: tool.systemImageName)
                                .renderingMode(.template)
                            Text(tool.toolName)
                        }
                    }
                )
            }
            .listStyle(.sidebar)
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

struct MacOSQuickPanelSettings: View {
    @ObservedObject var appConfig = AppConfiguration.shared
    
    var body: some View {
        Form {
            HStack {
                Text("Global Shortcut")
                Spacer()
                KeyboardShortcuts.Recorder(for: .togglePanel)
            }
                
            Picker("Provider", selection: $appConfig.quickPanelProvider) {
                ForEach(Provider.availableProviders, id: \.self) { provider in
                    Text(provider.name)
                }
            }
            
            Picker("Model", selection: $appConfig.quickPanelModel) {
                ForEach(appConfig.quickPanelProvider.chatModels, id: \.self) { model in
                    Text(model.name)
                }
            }
            
            TextField("Prompt", text: $appConfig.quickPanelPrompt)
                .textFieldStyle(.roundedBorder)
            
            Toggle("Google Search", isOn: $appConfig.qpIsGoogleSearchEnabled)
            Toggle("URL Scrape", isOn: $appConfig.qpIsUrlScrapeEnabled)
            Toggle("Image Generate", isOn: $appConfig.qpIsImageGenerateEnabled)
            Toggle("Transcribe", isOn: $appConfig.qpIsTranscribeEnabled)
            Toggle("Extract PDF", isOn: $appConfig.qpIsExtractPdfEnabled)
            Toggle("Vision", isOn: $appConfig.qpIsVisionEnabled)
        }
        .padding(30)
        .frame(width: 350, height: 300)
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
        }
        .padding(30)
    }
}

struct MacOSDefaultParameters: View {
    var body: some View {
        VStack(spacing: 20) {
            GroupBox(label: Text("Preferred Services")) {
                LabeledPicker(title: "Preferred Chat Provider", width: 300, picker: PreferredChatProvider())
                    .padding(10)
                    
                Divider()
                    
                LabeledPicker(title: "Preferred Image Provider", width: 300, picker: PreferredImageProvider())
                    .padding(10)
            }
            
            GroupBox(label: Text("Default Parameters")) {
                HStack {
                    Text("Temperature")
                    Spacer()
                    DefaultTempSlider()
                        .frame(width: widthValue)
                }
                .padding(paddingValue)

                Divider()

//                HStack {
//                    Text("Use Tools")
//                    Spacer()
//                    UseToolsPicker(isPicker: true)
//                        .labelsHidden()
//                        .frame(width: widthValue)
//                }
//                .padding(paddingValue)
//
//                Divider()
                
                HStack {
                    VStack {
                        Text("System prompt")
                        Spacer()
                    }
                    Spacer()
                    TextEditor(text: AppConfiguration.shared.$systemPrompt)
                        .scrollContentBackground(.hidden)
                        .padding(8)
                        .roundedRectangleOverlay(radius: 7)
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
