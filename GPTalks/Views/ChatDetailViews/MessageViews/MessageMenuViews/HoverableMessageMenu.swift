//
//  HoverableMessageMenu.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/12/2024.
//

import SwiftUI

struct HoverableMessageMenu<Content: View>: View {
    let content: () -> Content

    var body: some View {
        HStack {
            content()
                .buttonStyle(HoverScaleButtonStyle())
        }
        .frame(height: 25)
        .transaction { $0.animation = nil }
    }
}
