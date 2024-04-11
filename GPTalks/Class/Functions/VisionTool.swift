//
//  VisionTool.swift
//  GPTalks
//
//  Created by Zabir Raihan on 09/04/2024.
//

import Foundation

struct VisionParameters {
    let imagePaths: [String]
    let prompt: String
}

func extractVisionParameters(from jsonString: String) -> VisionParameters? {
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Error: Could not convert string to UTF-8 data.")
        return nil
    }

    do {
        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
           let prompt = jsonObject["prompt"] as? String {
            // Check if imagePaths is an array or a single string and handle accordingly
            var paths: [String] = []
            if let imagePathArray = jsonObject["imagePaths"] as? [String] {
                paths = imagePathArray
            } else if let imagePath = jsonObject["imagePaths"] as? String {
                paths = [imagePath] // Treat a single string as an array with one element
            }
            
            // Ensure we have at least one imagePath
            guard !paths.isEmpty else {
                print("Error: JSON does not contain valid 'imagePaths'.")
                return nil
            }
            
            return VisionParameters(imagePaths: paths, prompt: prompt)
        } else {
            print("Error: JSON does not contain valid 'prompt' or 'imagePaths' keys or they are not in the expected format.")
            return nil
        }
    } catch {
        print("Error parsing JSON: \(error)")
        return nil
    }
}
