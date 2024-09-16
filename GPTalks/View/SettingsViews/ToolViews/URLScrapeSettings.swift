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
                    Stepper(
                        "Content Length",
                        value: Binding<Double>(
                            get: { Double(config.maxContentLength) },
                            set: { config.maxContentLength = Int($0) }
                        ),
                        in: 500...20000,
                        step: 500,
                        format: .number
                    )
                    
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
