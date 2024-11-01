//
//  FileReaderSettings.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/10/2024.
//

import SwiftUI

struct FileReaderSettings: View {
    @ObservedObject var config = ToolConfigDefaults.shared
    
    var body: some View {
        Section("General") {
            Toggle("Enabled for new chats", isOn: $config.fileReader)
        }
        
//        Section {
//            IntegerStepper(value: $config.pdfMaxContentLength,
//                           label: "Content Length",
//                           secondaryLabel: "Number of prefix characters to return from each PDF",
//                           step: 500, range: 1000...100000)
//        }
    }
}

#Preview {
    FileReaderSettings()
}
