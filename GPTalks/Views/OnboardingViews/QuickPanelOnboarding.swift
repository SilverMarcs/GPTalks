//
//  QuickPanelOnboarding.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/11/2024.
//

#if os(macOS)
import SwiftUI
import KeyboardShortcuts

struct QuickPanelOnboarding: View {
    @Bindable var provider: Provider
    
    var body: some View {
        GenericOnboardingView(
            icon: "bolt.fill",
            iconColor: .yellow,
            title: "Spotlight-like Floating Panel",
            content: {
                Form {
                    LabeledContent {
                        KeyboardShortcuts.Recorder(for: .togglePanel)
                    } label: {
                        Text("Global shortcut")
                        Text("Access from anywhere in the OS")
                    }
                    
                    ModelPicker(model: $provider.liteModel, models: provider.chatModels, label: "Quick Panel Model")
                }
                .scrollDisabled(true)
                .formStyle(.grouped)
            },
            footerText: "You may configure further in Settings."
        )
    }
}


 #Preview {
     QuickPanelOnboarding(provider: .openAIProvider)
         .frame(width: 500, height: 500)
 }
#endif
