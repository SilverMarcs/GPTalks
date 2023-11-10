//
//  Extnsions.swift
//  GPTMessage
//
//  Created by Zabir Raihan on 10/11/2023.
//

import Foundation
import SwiftUIX
import Kingfisher

extension String {
    func copyToPasteboard() {
#if os(iOS)
        UIPasteboard.general.string = self
#else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self, forType: .string)
#endif
    }
}

extension KFCrossPlatformImage {
    func copyToPasteboard() {
#if os(iOS)
        UIPasteboard.general.image = self
#else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([self])
#endif
    }
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
}
