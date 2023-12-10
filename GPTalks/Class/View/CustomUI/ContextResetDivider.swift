//
//  ContextResetDivider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/12/2023.
//

import SwiftUI

struct ContextResetDivider: View {
    var body: some View {
        HStack {
            line
            Text("Context Cleared")
                .font(.footnote)
                .foregroundColor(.secondary)
            line
        }
    }
    
    var line: some View {
        Divider()
            .background(Color.gray)
    }
}

#Preview {
    ContextResetDivider()
}
