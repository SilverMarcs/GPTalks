//
//  Extnsions.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/11/2023.
//

import SwiftUI

#if !os(macOS)
var isIPadOS: Bool {
    UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.systemName == "iPadOS"
}
#endif

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

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

extension Date {
    func nowFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmssSSS"
        return formatter.string(from: self)
    }
}

func extractValue(from jsonString: String, forKey key: String) -> String? {
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Error: Could not convert string to UTF-8 data.")
        return nil
    }

    do {
        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
           let value = jsonObject[key] as? String {
            return value
        } else {
            print("Error: JSON does not contain a valid '\(key)' key.")
            return nil
        }
    } catch {
        print("Error parsing JSON: \(error)")
        return nil
    }
}


func extractValues(from jsonString: String) -> [String: String]? {
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Error: Could not convert string to UTF-8 data.")
        return nil
    }

    do {
        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
            var valuesDict: [String: String] = [:]
            for (key, value) in jsonObject {
                if let stringValue = value as? String {
                    valuesDict[key] = stringValue
                }
            }
            return valuesDict.isEmpty ? nil : valuesDict
        } else {
            print("Error: JSON does not contain valid keys and values.")
            return nil
        }
    } catch {
        print("Error parsing JSON: \(error)")
        return nil
    }
}
func isAudioFile(urlString: String) -> Bool {
     guard let url = URL(string: urlString) else { return false }

     // Determine the file's Uniform Type Identifier (UTI)
     guard let uti = try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else { return false }

     // Popular audio UTIs
     let audioTypes = [
         "public.mp3",
         "public.mpeg-4",
         "public.aiff-audio",
         "com.apple.coreaudio-format",
         "public.audiovisual-content"
         // Add more audio types if needed
     ]

     return audioTypes.contains(uti)
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

#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

extension Image {
    init(platformImage: PlatformImage) {
#if os(macOS)
        self.init(nsImage: platformImage)
#else
        self.init(uiImage: platformImage)
#endif
    }
}


func getFileSizeFormatted(fileURL: URL) -> String? {
    do {
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        
        if let fileSize = attributes[FileAttributeKey.size] as? NSNumber {
            return formatBytes(bytes: fileSize.intValue)
        } else {
            print("Could not find file size.")
            return nil
        }
    } catch {
        print("Error getting file size: \(error.localizedDescription)")
        return nil
    }
}

func formatBytes(bytes: Int) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
    formatter.countStyle = .file
    formatter.includesUnit = true
    formatter.isAdaptive = true
    return formatter.string(fromByteCount: Int64(bytes))
}

#if os(macOS)
func getFileTypeIcon(fileURL: URL) -> NSImage? {
    return NSWorkspace.shared.icon(forFile: fileURL.path)
}
#endif
