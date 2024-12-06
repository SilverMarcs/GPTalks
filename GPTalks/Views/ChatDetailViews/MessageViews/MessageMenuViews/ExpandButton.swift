//
//  ExpandButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct ExpandButton: View {
    @Binding var isExpanded: Bool
    var message: MessageGroup
    
    var body: some View {
        if message.role == .user {
            Button {
                isExpanded.toggle()
                AppConfig.shared.proxy?.scrollTo(message, anchor: .top)
            } label: {
                Label(isExpanded ? "Collapse" : "Expand", 
                      systemImage: isExpanded ? "arrow.up.right.and.arrow.down.left" : "arrow.down.left.and.arrow.up.right")
            }
            .contentTransition(.symbolEffect(.replace))
            .help("Expand")
        }
    }
}
