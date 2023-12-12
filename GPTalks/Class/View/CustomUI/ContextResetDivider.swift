//
//  ContextResetDivider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/12/2023.
//

import SwiftUI

struct ContextResetDivider: View {
    @ObservedObject var session: DialogueSession
    
    var body: some View {
        VStack {
            HStack {
                            line
                Text("Context Cleared")
                    .foregroundColor(.secondary)
                
                Button(role: .destructive) {
                    session.removeResetContextMarker()
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                
                            line

            }
            
            Divider()
        }
    }
    
    var line: some View {
        Divider()
            .background(Color.gray)
    }
}
