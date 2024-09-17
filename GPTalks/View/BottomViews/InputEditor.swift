//
//  InputEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct InputEditor: View {
    @Binding var prompt: String
    var provider: Provider
    @FocusState var isFocused: Bool
    
    var body: some View {
        #if os(macOS)
        MacInputEditor(prompt: $prompt, provider: provider, isFocused: _isFocused)
        #else
        iOSInputEditor(prompt: $prompt, provider: provider, isFocused: _isFocused)
        #endif
    }
}

#Preview {
    InputEditor(prompt: .constant("Hello, World!"), provider: Provider.factory(type: .openai))
}
