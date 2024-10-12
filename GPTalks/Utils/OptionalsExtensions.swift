//
//  OptionalsExtensions.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/10/2024.
//

import Foundation

extension Optional {
    func unwrapOrThrow(error: Error) throws -> Wrapped {
        guard let value = self else {
            throw error
        }
        return value
    }
}
