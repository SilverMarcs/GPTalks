//
//  URLScrapeSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

struct URLScrapeSettings: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    
    var body: some View {
        Section("General") {
            Toggle("Enabled for new chats", isOn: $config.urlScrape)
        }
        
        Section {
            VStack {
                VStack(alignment: .leading) {
                    IntegerStepper(value: $config.maxContentLength, label: "Content Length", step: 500, range: 500...20000)
                    
                    Text("Number of prefix characters to return from each url")
                       .font(.caption)
                       .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    URLScrapeSettings()
}
