//
//  CommonModifiers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI
//import VisualEffectView

struct CommonInputStyling: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
            .padding(.vertical, verticalPadding)
            #if os(macOS)
            .background(.bar)
            #else
            .background(
//                VisualEffect(
//                    colorTint: colorScheme == .dark ? .black : .white,
//                    colorTintAlpha: 0.7,
//                    blurRadius: 15,
//                    scale: 1
//                )
//                .ignoresSafeArea()
                .background
//                    .ignoresSafeArea()
            )
                #if os(visionOS)
                .background(.regularMaterial)
                #endif
            #endif
            .ignoresSafeArea()
        
    }
    
    private var verticalPadding: CGFloat {
#if os(macOS)
        14
#else
        9
#endif
    }
}

#Preview {
    ChatInputView(session: .mockChatSession)
        .modifier(CommonInputStyling())
}
