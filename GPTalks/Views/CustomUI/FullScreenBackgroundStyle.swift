//
//  FullScreenBackgroundStyle.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/11/2024.
//

import SwiftUI

struct FullScreenBackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            #if !os(visionOS)
            .background(.background)
            #endif
            #if os(macOS)
            .toolbarBackground(.hidden)
            #endif
    }
}

extension View {
    func fullScreenBackground() -> some View {
        self.modifier(FullScreenBackgroundStyle())
    }
}

