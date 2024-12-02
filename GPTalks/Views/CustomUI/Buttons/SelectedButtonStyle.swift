//
//  SelectedButtonStyle.swift
//  GPTalks
//
//  Created by Zabir Raihan on 30/11/2024.
//

import SwiftUI

struct SelectedButtonStyle: ButtonStyle {
    @Binding var isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(5)
            .background(isSelected || configuration.isPressed ? .accent.opacity(0.3) : .clear)
            .cornerRadius(5)
    }
}

extension ButtonStyle where Self == SelectedButtonStyle {
    static func selected(_ isSelected: Binding<Bool>) -> SelectedButtonStyle {
        SelectedButtonStyle(isSelected: isSelected)
    }
}
