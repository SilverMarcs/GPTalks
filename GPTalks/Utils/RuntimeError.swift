//
//  RuntimeError.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/10/2024.
//

import Foundation

struct RuntimeError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}
