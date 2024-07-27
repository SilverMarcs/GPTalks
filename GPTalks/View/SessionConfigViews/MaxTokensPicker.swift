//
//  MaxTokensPicker.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct MaxTokensPicker: View {
    @Binding var value: Int?
    let defaultValue: Int = 4096 // You can adjust this default value as needed
    
    var body: some View {
        if let value = value {
            Picker("Max Tokens", selection: $value) {
                ForEach(options, id: \.self) { option in
                    Text(String(option)).tag(option)
                }
            }
        } else {
            HStack {
                Text("Max Tokens")
                Spacer()
                Button("Set") {
                    self.value = defaultValue
                }
                .buttonStyle(.plain)
                .foregroundStyle(.link)
            }
        }
    }
    
    let options = [512, 1024, 2048, 4096, 8192]
}

//#Preview {
//    MaxTokensPicker()
//}
