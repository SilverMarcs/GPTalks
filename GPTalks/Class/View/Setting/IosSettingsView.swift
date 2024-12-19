//
//  AppSettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI

#if !os(macOS)
struct IosSettingsView: View {
    @ObservedObject var configuration: AppConfiguration = AppConfiguration.shared
    @Environment(\.dismiss) var dismiss
    
    @State var showAPIKey = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .renderingMode(.original)
                        Spacer()
                        Toggle("Markdown Enabled", isOn: $configuration.isMarkdownEnabled)
                    }

                    HStack {
                        Image(systemName: "textformat")
                            .renderingMode(.original)
                        Spacer()
                        Toggle("AutoGen Title", isOn: $configuration.isAutoGenerateTitle)
                    }
                    
                    HStack {
                        Image(systemName: "play.fill")
                            .renderingMode(.original)
                        Spacer()
                        Toggle("Auto Resume", isOn: $configuration.autoResume)
                    }
                }
                
                Section("Preferred Services") {
                    HStack {
                        Image(systemName: "building.2.fill")
                            .renderingMode(.original)
                        Text("Chat Provider")
                            .lineLimit(1)
                        Spacer()
                        Picker("", selection: configuration.$preferredChatService) {
                            ForEach(Provider.availableProviders, id: \.self) { provider in
                                Text(provider.name)
                                    .tag(provider.id)
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .renderingMode(.original)
                        Text("Image Provider")
                            .lineLimit(1)
                        Spacer()
                        Picker("", selection: configuration.$preferredImageService) {
                            ForEach(Provider.availableProviders, id: \.self) { provider in
                                Text(provider.name)
                                    .tag(provider.id)
                            }
                        }
                    }
                }
                
                Section("Chat Features") {
                    NavigationLink {
                        IosDefaultConfigView()
                    } label: {
                        HStack {
                            Image(systemName: "cpu.fill")
                                .renderingMode(.original)
                            Text("Default Parameters")
                        }
                    }
                }
                
                Section("Services") {
                    ForEach(Provider.availableProviders) { provider in
                        NavigationLink(
                            destination: provider.destination,
                            label: { provider.settingsLabel }
                        )
                    }
                }
                
                Section("App Icon") {
                    NavigationLink(
                        destination: AppIconView(),
                        label: {
                            HStack {
                                Image(systemName: "app.fill")
                                    .renderingMode(.original)
                                Text("App Icon")
                            }
                        }
                    )
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}
#endif
