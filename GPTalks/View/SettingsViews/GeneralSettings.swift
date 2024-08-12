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
                Toggle("Folder View", isOn: $config.folderView)
            } header: {
                Text("Experimental")
            } footer: {
                SectionFooterView(text: "Use Folders in SessionList. Extremeley buggy at the moment")
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
