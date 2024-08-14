//
//  ContextResetDivider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/07/2024.
//

import SwiftUI

struct ContextResetDivider: View {
    var reset: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("Context Cleared")
                
                Button(role: .destructive) {
//                    withAnimation {
                        reset()
//                    }
                } label: {
                    Image(systemName: "delete.backward")
                }
                .buttonStyle(.plain)
            }
            
            Divider()
        }
        .foregroundStyle(.secondary)
    }
}

#Preview {
    ContextResetDivider() {
        
    }
    .padding()
}
