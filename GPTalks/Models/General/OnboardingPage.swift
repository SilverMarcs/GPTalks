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
    case quickPanel
    case imageGen
    case ready
    
    var title: String {
        switch self {
        case .welcome: "Welcome"
        case .apiKey: "API Key"
        case .plugins: "Plugins"
        case .quickPanel: "Quick Panel"
        case .imageGen: "Image Generation"
        case .ready: "Ready"
        }
    }
}
