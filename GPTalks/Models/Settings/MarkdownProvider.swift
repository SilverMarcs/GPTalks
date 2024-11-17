//
//  MarkdownProvider.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/11/2024.
//

import Foundation

enum MarkdownProvider: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case native
    case webview
    
    var name: String {
        switch self {
        case .native:
            return "Native"
        case .webview:
            return "Webview"
        }
    }
    
    var info: String {
        switch self {
        case .native:
            "Native Uses less memory but is less performant"
        case .webview:
            "Webview Uses more memory but is more performant"
        }
    }
}
