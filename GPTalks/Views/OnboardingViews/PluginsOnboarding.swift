//
//  PluginsOnboarding 2.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI

struct PluginsOnboarding: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    
    var body: some View {
        GenericOnboardingView(
            icon: "hammer.fill",
            iconColor: .cyan,
            title: "Connect LLMs with plugins",
            content: {
                Form {
                    Section {
                        Toggle("URL Scrape", isOn: $config.urlScrape)
                        Toggle("Google Search", isOn: $config.googleSearch)
                        Toggle("Image Generate", isOn: $config.imageGenerate)
                        Toggle("Transcribe", isOn: $config.transcribe)
                    }
                    #if os(iOS)
                    .listRowBackground(Color(.secondarySystemBackground))
                    #endif
                }
            },
            footerText: "Disable plugins if LLMs behave unexpectedly"
        )
    }
}

#Preview {
    PluginsOnboarding()
        .frame(width: 500, height: 500)
}
