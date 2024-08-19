//
//  GeneralSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI
import TipKit

struct GeneralSettings: View {
    @ObservedObject var config = AppConfig.shared

    var body: some View {
        Form {
            Section {
                Toggle("Autogen Title", isOn: $config.autogenTitle)
            } header: {
                Text("Title")
            } footer: {
                SectionFooterView(text: "Uses Title model in provider general settings")
            }
            
            Section {
                Toggle("Expensive Search", isOn: $config.expensiveSearch)
            } header: {
                Text("Search")
            } footer: {
                SectionFooterView(text: "Expensive method searches all messages but may cause UI responsiveness issues")
            }
            
            Section {
                Button {
                    try? Tips.resetDatastore()
                } label: {
                    Label("Reset Tips", systemImage: "exclamationmark.triangle")
                }
                .foregroundStyle(.cyan)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("General")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    GeneralSettings()
}
