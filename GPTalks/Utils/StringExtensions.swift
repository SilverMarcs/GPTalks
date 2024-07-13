//
//  StringExtensions.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import Foundation
import SwiftUI

extension String {
    func copyToPasteboard() {
#if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self, forType: .string)
#else
        UIPasteboard.general.string = self
#endif
    }
    
    static let bottomID = "bottomID"
    
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        } else {
            return self
        }
    }
    
    func absoluteURL() -> URL? {
        // Get the URL for the Documents directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // Append the relative path to the Documents directory URL
        let fileURL = documentsDirectory.appendingPathComponent(self)
        
        return fileURL
    }
}
