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
    
    var body: some View {
        #if os(macOS)
        MacInputEditor(prompt: $prompt, provider: provider)
        #else
        iOSInputEditor(prompt: $prompt, provider: provider)
        #endif
    }
}

#Preview {
    InputEditor(prompt: .constant("Hello, World!"), provider: Provider.factory(type: .openai))
}
