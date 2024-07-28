//
//  DeviceCheckers.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI

func isIPadOS() -> Bool {
    #if os(macOS)
    return false
    #else
    return UIDevice.current.userInterfaceIdiom == .pad
    #endif
}

func isIOS() -> Bool {
    #if os(macOS)
    return false
    #else
    return UIDevice.current.userInterfaceIdiom == .phone
    #endif
}

#if !os(macOS)
extension View {
    @ViewBuilder
    func ifIsPad<TrueContent: View, FalseContent: View>(
        @ViewBuilder isTrueContent: (Self) -> TrueContent,
        @ViewBuilder else isFalseContent: (Self) -> FalseContent
    ) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            isTrueContent(self)
        } else {
            isFalseContent(self)
        }
        
    }
}
#endif
