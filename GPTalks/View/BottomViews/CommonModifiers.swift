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
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
            .padding(.top, verticalPadding - 5)
            .padding(.bottom, verticalPadding)
            #if os(macOS)
            .background(.bar)
            #else
            .background(.background)
            #if os(visionOS)
            .background(.regularMaterial)
            #endif
            #endif
            .ignoresSafeArea()
        
    }
    
    private var verticalPadding: CGFloat {
#if os(macOS)
        16
#else
        9
#endif
    }
}

#Preview {
    ChatInputView(session: .mockChatSession)
        .modifier(CommonInputStyling())
}
