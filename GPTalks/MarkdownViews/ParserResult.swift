//
//  ParserResult.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/3/24.
//

import Foundation

struct ParserResult: Identifiable {
    let id = UUID()
    let attributedString: AttributedString
    let isCodeBlock: Bool
    let codeBlockLanguage: String?
}
