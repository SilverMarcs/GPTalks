//
//  TextUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/9/24.
//

import SwiftUI

struct CaptionSecondaryStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

extension View {
    func captionSecondaryStyle() -> some View {
        self.modifier(CaptionSecondaryStyle())
    }
}
