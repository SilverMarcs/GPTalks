//
//  SecondaryNavigationButtons.swift
//  GPTalks
//
//  Created by Zabir Raihan on 01/12/2024.
//

import SwiftUI

struct SecondaryNavigationButtons: View {
    var group: MessageGroup
    
    var body: some View {
        if group.secondaryMessages.count > 1 {
            HStack {
                Button {
                    group.previousSecondaryMessage()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }
                .disabled(!group.canGoToPreviousSecondary)
                .opacity(!group.canGoToPreviousSecondary ? 0.5 : 1)
                
                Button {
                    group.nextSecondaryMessage()
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
                .disabled(!group.canGoToNextSecondary)
                .opacity(!group.canGoToNextSecondary ? 0.5 : 1)
            }
            .buttonStyle(HoverScaleButtonStyle())
        }
    }
}

#Preview {
    SecondaryNavigationButtons(group: .mockUserGroup)
}
