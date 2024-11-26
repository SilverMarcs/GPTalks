//
//  CodeTheme.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import SwiftUI
import HighlightSwift
import SwiftMarkdownView

public enum CodeTheme: String, CaseIterable, Identifiable, Codable, Equatable {
    case a11y = "A11Y"
    case atomOne = "Atom One"
    case github = "GitHub"
    case pandaSyntax = "Panda"
    case paraiso = "Paraiso"
    case stackoverflow = "StackOverflow"
    case tokyoNight = "Tokyo"

    public var id: String {
        rawValue
    }

    func toHighlightTheme() -> HighlightTheme {
        switch self {
        case .a11y:
            return .a11y
        case .atomOne:
            return .atomOne
        case .github:
            return .github
        case .pandaSyntax:
            return .pandaSyntax
        case .paraiso:
            return .paraiso
        case .stackoverflow:
            return .stackoverflow
        case .tokyoNight:
            return .tokyoNight
        }
    }

    func toCodeBlockTheme() -> CodeBlockTheme {
        switch self {
        case .a11y:
            return .a11y
        case .atomOne:
            return .atom
        case .github:
            return .github
        case .pandaSyntax:
            return .panda
        case .paraiso:
            return .paraiso
        case .stackoverflow:
            return .stackoverflow
        case .tokyoNight:
            return .tokyo
        }
    }
}
