//
//  iOSInputEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI

struct iOSInputEditor: View {
    @Binding var prompt: String
    @FocusState var isFocused: Bool
    var provider: Provider
    
    var body: some View {
            TextField(placeHolder, text: $prompt, axis: .vertical)
                .focused($isFocused)
                .lineLimit(10, reservesSpace: false)
    }
    
    var placeHolder: String {
        "Send a prompt • \(provider.name)"
    }
    
    var leadingPadding: CGFloat {
        return 10
    }
}
