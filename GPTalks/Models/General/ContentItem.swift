//
//  ContentItem.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import Foundation

enum ContentItem {
    case text(NSAttributedString)
    case codeBlock(NSAttributedString, language: String?)
}

