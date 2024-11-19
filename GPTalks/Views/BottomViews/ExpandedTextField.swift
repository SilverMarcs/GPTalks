//
//  ExpandedTextField.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/07/2024.
//

import SwiftUI

struct ExpandedTextField: View {
    @Binding var prompt: String
    @FocusState var isFocused: Bool
    
    var body: some View {
        Form {
            TextField("Send a message", text: $prompt, axis: .vertical)
                .focused($isFocused)
                .task {
                    isFocused = true
                }
        }
    }
}
