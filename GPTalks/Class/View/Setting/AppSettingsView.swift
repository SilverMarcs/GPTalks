//
//  AppSettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI

#if os(iOS)
struct AppSettingsView: View {
    @ObservedObject var configuration: AppConfiguration = AppConfiguration.shared
    @Environment(\.dismiss) var dismiss
    
    @State var showAPIKey = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .renderingMode(.original)
                        Spacer()
                        Toggle("Markdown Enabled", isOn: $configuration.isMarkdownEnabled)
                    }
                    HStack {
                        Image(systemName: "building.2.fill")
                            .renderingMode(.original)
                        Text("Default Provider")
                            .lineLimit(1)
                        Spacer()
                        Picker("", selection: configuration.$preferredChatService) {
                            ForEach(Provider.allCases, id: \.self) { provider in
                                Text(provider.name)
                                    .tag(provider.id)
                            }
                        }
                    }
                }
                Section("Defaults") {
                    NavigationLink {
                        DefaultConfigView()
                    } label: {
                        HStack {
                            Image(systemName: "cpu.fill")
                                .renderingMode(.original)
                            Text("Default Parameters")
                        }
                    }
                }
                Section("Services") {
                    ForEach(Provider.allCases) { provider in
                        NavigationLink(
                            destination: provider.destination,
                            label: { provider.label }
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
