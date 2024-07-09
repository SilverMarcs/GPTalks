//
//  GPTEncoder.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/07/2024.
//

import Foundation
import GPTEncoder

let sharedEncoder = GPTEncoder()

func tokenCount(text: String) -> Int {
    let encoded = sharedEncoder.encode(text: text)
    return encoded.count
}
