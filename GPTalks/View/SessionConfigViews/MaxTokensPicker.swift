//
//  MaxTokensPicker.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct MaxTokensPicker: View {
    @Binding var value: Int
    
    var body: some View {
        Picker("Max Tokens", selection: $value) {
            ForEach(options, id: \.self) { option in
                Text(String(option)).tag(option)
            }
        }
    }
    
    let options = [512, 1024, 2048, 4096, 8192]
}

//#Preview {
//    MaxTokensPicker()
//}
