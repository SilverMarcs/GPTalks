//
//  PlatformSpecificGroupBoxStyle.swift
//  GPTalks
//
//  Created by Zabir Raihan on 31/10/2024.
//

import SwiftUI

struct PlatformSpecificGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        GroupBox {
            configuration.content
            #if !os(macOS)
                .padding(EdgeInsets(top: -6, leading: -5, bottom: -6, trailing: -5)) // iOS by default has extra large padding
            #endif
        } label: {
            configuration.label
        }
    }
}
