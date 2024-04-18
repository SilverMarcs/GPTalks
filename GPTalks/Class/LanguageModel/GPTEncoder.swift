//
//  Encoder.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/04/2024.
//

import Foundation
import GPTEncoder

// Assuming GPTEncoder is a class that cannot be modified to use the singleton pattern
let sharedEncoder = GPTEncoder()

func tokenCount(text: String) -> Int {
    let encoded = sharedEncoder.encode(text: text)
    return encoded.count
}

extension Int {
    func formatToK() -> String {
        let number = Double(self)
        return String(format: "%.2fK", number / 1000)
    }
}
