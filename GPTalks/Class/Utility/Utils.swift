//
//  Extnsions.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
    // does chunking from bottom up
    func chunked(fromEndInto size: Int) -> [[Element]] {
        reversed().chunked(into: size).map { $0.reversed() }.reversed()
    }
}

func extractURL(from jsonString: String) -> String? {
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Error: Could not convert string to UTF-8 data.")
        return nil
    }

    do {
        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
           let url = jsonObject["url"] as? String {
            print("Web content url: \(url)")
            return url
        } else {
            print("Error: JSON does not contain a valid 'url' key.")
            return nil
        }
    } catch {
        print("Error parsing JSON: \(error)")
        return nil
    }
}


extension String {
    func copyToPasteboard() {
#if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self, forType: .string)
#else
        UIPasteboard.general.string = self
#endif
    }
    
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        } else {
            return self
        }
    }
}


func scrollToBottom(proxy: ScrollViewProxy, id: String = "bottomID", anchor: UnitPoint = .bottom, animated: Bool = true, delay: TimeInterval = 0.0) {
   let action = {
       if animated {
           withAnimation {
               proxy.scrollTo(id, anchor: anchor)
           }
       } else {
           proxy.scrollTo(id, anchor: anchor)
       }
   }

   if delay > 0 {
       DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: action)
   } else {
       DispatchQueue.main.async(execute: action)
//       action()
   }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

#if os(macOS)
extension NSImage {
    var base64: String? {
        self.tiffRepresentation?.base64EncodedString()
    }
    
    func base64EncodedString(compressionFactor: CGFloat = 0.7) -> String? {
        guard let imageData = self.tiffRepresentation,
              let imageRep = NSBitmapImageRep(data: imageData),
              let jpegData = imageRep.representation(using: .jpeg, properties: [.compressionFactor: compressionFactor]) else {
            return nil
        }
        return jpegData.base64EncodedString()
    }
}

extension String {
    var imageFromBase64: NSImage? {
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return NSImage(data: imageData)
    }
}


#else
extension UIImage {
    var base64: String? {
        self.jpegData(compressionQuality: 0.7)?.base64EncodedString()
    }
    
    func base64EncodedString(compressionQuality: CGFloat = 0.7) -> String? {
        guard let jpegData = self.jpegData(compressionQuality: compressionQuality) else {
           return nil
        }
        return jpegData.base64EncodedString()
    }
    
}

extension String {
    var imageFromBase64: UIImage? {
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}

#endif
