//
//  CommonModifiers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct CommonInputStyling: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(3)
            .roundedRectangleOverlay()
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
            .padding(.top, verticalPadding - 5)
            .padding(.bottom, verticalPadding)
            #if os(macOS) || os(visionOS)
            .background(.bar)
            #else
            .background(.background)
            #endif
            .ignoresSafeArea()
    }
    
    private let verticalPadding: CGFloat = 16
}

#Preview {
    ChatInputView(chat: .mockChat)
        .modifier(CommonInputStyling())
}
