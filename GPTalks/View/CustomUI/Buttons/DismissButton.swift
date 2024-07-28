//
//  DismissButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/07/2024.
//

import SwiftUI

struct DismissButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            #if os(visionOS)
            Image(systemName: "xmark")
            #else
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.gray, .gray.opacity(0.3))
            #endif
        }
    }
}

#Preview {
    DismissButton()
}
