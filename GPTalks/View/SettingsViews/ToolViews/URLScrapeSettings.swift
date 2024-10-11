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
            IntegerStepper(value: $config.urlMaxContentLength,
                           label: "Content Length",
                           secondaryLabel: "Number of prefix characters to return from each url",
                           step: 500, range: 1000...30000)
        }
    }
}

#Preview {
    URLScrapeSettings()
}
