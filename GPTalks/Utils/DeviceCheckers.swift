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
