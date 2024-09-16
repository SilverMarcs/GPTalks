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
    static let topID = "topID"
    static let testPrompt = "Respond with just the word Test"
    
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
    
    func truncateText() -> String {
        let maxCharacters = 20
        
        if self.count > maxCharacters {
            let prefixLength = maxCharacters / 2 - 1
            let suffixLength = maxCharacters / 2 - 1
            let prefix = self.prefix(prefixLength)
            let suffix = self.suffix(suffixLength)
            return "\(prefix)...\(suffix)"
        } else {
            return self
        }
    }
    
    static private let demoAssistant: String =
    """
    This is a code block.
    
    ```swift
    struct ContentView: View {
        var body: some View {
            Text("Hello, World!")
        }
    }
    ```
    
    Thank you for using me.
    """
    
    static private let demoAssistant2: String =
    """
    ## Heading   
    There are three ways to print a string in python
    1. Not printing
    2. Printing carelessly
    3. Blaming it on Teammates
    
    ### Subheading
    But whats even better is the ability to see into the future.  
        
    Thank you for using me.
    """
    
    static let assistantDemos = [demoAssistant, demoAssistant2]
    
    static private let demoImage: String = "file:///Users/Zabir/Pictures/GPTalks/20240718_203104560.jpg"
    static private let demoImage2: String = "file:///Users/Zabir/Pictures/GPTalks/20240718_203358964.jpg"
    static let demoImages = [demoImage, demoImage2]
}
