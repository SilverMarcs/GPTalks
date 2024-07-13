//
//  SettingsView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
#if os(iOS)
        NavigationStack {
            List {
                NavigationLink("General", destination: GeneralSettings())
                NavigationLink("Parameters", destination: ParameterSettings())
                NavigationLink("Providers", destination: ProviderList())
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
#else
        TabView {
            settingsTab(content: GeneralSettings(), label: "General", icon: "gear")
            
            settingsTab(content: QuickPanelSettings(), label: "Quick Panel", icon: "bolt.fill")
            
            settingsTab(content: ParameterSettings(), label: "Parameters", icon: "slider.horizontal.3")
            
            settingsTab(content: ProviderList(), label: "Providers", icon: "cpu", padding: 0)
        }
#endif
    }
    
#if os(macOS)
    @ViewBuilder
    private func settingsTab<Content: View>(content: Content, label: String, icon: String, padding: CGFloat = 80) -> some View {
        content
            .padding(.horizontal, padding)
            .frame(width: 700)
            .tabItem {
                Label(label, systemImage: icon)
            }
    }
#endif
}

#Preview {
    SettingsView()
}
