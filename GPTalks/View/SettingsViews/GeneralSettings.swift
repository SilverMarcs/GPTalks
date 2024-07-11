//
//  GeneralSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

struct GeneralSettings: View {
    @ObservedObject var config = AppConfig.shared

    var body: some View {
        Form {
            Section("Markdown") {
                Toggle("Assistant Message Markdown", isOn: $config.assistantMarkdown)
            }
            
            Section("Behaviour") {
                Toggle("Autogen Title", isOn: $config.autogenTitle)
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    GeneralSettings()
}
