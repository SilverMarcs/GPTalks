//
//  ContentItem.swift
//  GPTalks
//
//  Created by Zabir Raihan on 26/11/2024.
//

import Foundation
import Markdown

enum ContentItem {
    case text(NSAttributedString)
    case codeBlock(String, language: String?)
    case table(Table)
    case latex(String)
}
