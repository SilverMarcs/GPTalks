//
//  OnboardingPage.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/11/2024.
//

import Foundation

enum OnboardingPage: Int, CaseIterable {
    case welcome
    case apiKey
    case plugins
    #if os(macOS)
    case quickPanel
    #endif
    case imageGen
    case ready
}
