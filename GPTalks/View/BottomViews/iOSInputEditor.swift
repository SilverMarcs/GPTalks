//
//  iOSInputEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 16/09/2024.
//

import SwiftUI


struct iOSInputEditor: View {
    @Environment(ChatSessionVM.self) private var sessionVM
    
    @Environment(\.colorScheme) var colorScheme
    @Binding var prompt: String
    var provider: Provider
    @FocusState var isFocused: Bool
    
    @State private var showPopover: Bool = false
    
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
