//
//  MarkdownProvider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/11/2024.
//

import Foundation

enum MarkdownProvider: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case disabled
    case basic
    case native
    case webview
    
    var name: String {
        switch self {
        case .disabled:
            "Disabled"
        case .basic:
            "Basic"
        case .native:
            "Native"
        case .webview:
            "Webview"
        }
    }
}
