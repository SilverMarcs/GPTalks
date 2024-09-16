//
//  GenerateImageSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI

struct GenerateImageSettings: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    
    var body: some View {
        Section("General") {
            Toggle("Enabled for new chats", isOn: $config.imageGenerate)
        }
    }
}

#Preview {
    GenerateImageSettings()
}
