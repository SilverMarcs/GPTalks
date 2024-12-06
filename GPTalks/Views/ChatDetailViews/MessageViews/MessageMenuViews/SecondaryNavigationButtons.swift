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
            Button {
                group.previousSecondaryMessage()
            } label: {
                Label("Previous", systemImage: "chevron.left")
            }
            .buttonStyle(HoverScaleButtonStyle())
            .disabled(!group.canGoToPreviousSecondary)
            .opacity(!group.canGoToPreviousSecondary ? 0.5 : 1)
            
            Button {
                group.nextSecondaryMessage()
            } label: {
                Label("Next", systemImage: "chevron.right")
            }
            .buttonStyle(HoverScaleButtonStyle())
            .disabled(!group.canGoToNextSecondary)
            .opacity(!group.canGoToNextSecondary ? 0.5 : 1)
        }
    }
}

#Preview {
    SecondaryNavigationButtons(group: .mockUserGroup)
}
