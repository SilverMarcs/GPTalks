//
//  FileHelper.swift
//  GPTalks
//
//  Created by Zabir Raihan on 24/07/2024.
//

import Foundation

struct FileHelper {
    static func deleteFile(at path: String) {
        do {
            #if os(macOS)
            if let fileURL = URL(string: path) {
                try Foundation.FileManager.default.removeItem(at: fileURL)
            }
            #else
            let documentsDirectory = try Foundation.FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentsDirectory.appendingPathComponent(path)
            try Foundation.FileManager.default.removeItem(at: fileURL)
            #endif
            print("Successfully deleted file at: \(path)")
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }
}
