//
//  IntegerExtensions.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import Foundation

extension Int {
    func formatToK() -> String {
        let number = Double(self)
        return String(format: "%.2fK", number / 1000)
    }
}

extension Float {
    static let UIIpdateInterval = 0.4
}
