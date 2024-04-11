//
//  ImageGenerateTool.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/04/2024.
//

import Foundation

struct ImageParameters {
    let prompt: String
    let n: Int
}

func extractImageParameters(from jsonString: String) -> ImageParameters? {
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Error: Could not convert string to UTF-8 data.")
        return nil
    }

    do {
        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
           let prompt = jsonObject["prompt"] as? String,
           let nString = jsonObject["n"] as? String,
           let n = Int(nString) {
            return ImageParameters(prompt: prompt, n: n)
        } else {
            print("Error: JSON does not contain valid 'prompt' and 'n' keys or they are not in the expected format.")
            return nil
        }
    } catch {
        print("Error parsing JSON: \(error)")
        return nil
    }
}
