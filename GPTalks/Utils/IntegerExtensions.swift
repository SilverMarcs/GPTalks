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
    
    func formatFileSize() -> String {
        let kb = Double(self) / 1024.0
        let mb = kb / 1024.0
        let gb = mb / 1024.0
        
        if gb >= 1.0 {
            return String(format: "%.2f GB", gb)
        } else if mb >= 1.0 {
            return String(format: "%.2f MB", mb)
        } else {
            return String(format: "%.2f KB", kb)
        }
    }
}

extension Float {
    static let UIIpdateInterval = 0.4
}
