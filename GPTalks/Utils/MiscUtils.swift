//
//  SwiftDataUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/07/2024.
//

import SwiftUI
import SwiftData

// MARK: - ModelContext
extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            url
        } else {
            "No SQLite database found."
        }
    }
}

// MARK: - Device Detection
func isIPadOS() -> Bool {
    #if os(macOS)
    return false
    #else
    return UIDevice.current.userInterfaceIdiom == .pad
    #endif
}

// MARK: - Keyboard Shortcuts
#if os(macOS)
import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let togglePanel = Self("togglePanel")
}
#endif

// MARK: - Platform Color
#if os(macOS)
typealias PlatformColor = NSColor
#else
typealias PlatformColor = UIColor
#endif

// MARK: - Numbers

extension Float {
    static let UIIpdateInterval = 0.4
}

// MARK: - String
extension String {
    static let bottomID = "bottomID"
    static let topID = "topID"
    static let testPrompt = "Respond with just the word Test"
    
    func copyToPasteboard() {
#if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self, forType: .string)
#else
        UIPasteboard.general.string = self
#endif
    }
    
    func cleanMarkdown() -> String {
        let markdownCharacters = CharacterSet(charactersIn: "#*_`!:^")
        let cleanedText = self.components(separatedBy: markdownCharacters).joined()
        return cleanedText
    }
}

// MARK: - Scrolling
func scrollToBottom(proxy: ScrollViewProxy, id: String = String.bottomID, anchor: UnitPoint = .bottom, animated: Bool = true, delay: TimeInterval = 0.0) {
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
    }
}

// MARK: - Error
struct RuntimeError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}

// MARK: - Environment Values
extension EnvironmentValues {
    @Entry var isSearch: Bool = false

    @Entry var providers: [Provider] = []
    
    @Entry var isQuick: Bool = false

    #if os(macOS)
    @Entry var floatingPanel: NSPanel? = nil
    #endif
}

// MARK: - Image
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

extension PlatformImage {
    static func from(data: Data) -> PlatformImage? {
        #if os(macOS)
        return NSImage(data: data)
        #else
        return UIImage(data: data)
        #endif
    }
}

// MARK: - Color
extension Color {
    // Initialize Color from hex string
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
        case 8: // RGBA (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
    
    // Convert Color to hex string
    func toHex(includeAlpha: Bool = true) -> String {
        guard let components = self.cgColor?.components else {
            return "#FFFFFFFF"
        }
        
        let r, g, b, a: CGFloat
        
        if components.count == 2 {
            r = components[0]
            g = components[0]
            b = components[0]
            a = components[1]
        } else if components.count == 4 {
            r = components[0]
            g = components[1]
            b = components[2]
            a = components[3]
        } else {
            return "#FFFFFFFF"
        }
        
        if includeAlpha {
            return String(format: "#%02lX%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)), lroundf(Float(a * 255)))
        } else {
            return String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        }
    }
    
    static let randomColors: [String] = [
        "#438DAD",
        "#4B62CA",
        "#376288",
        "#006CF9",
        "#B53651",
        "#A8656C",
        "#9D6293",
        "#6A5678",
        "#A25277"
    ]
    
    
    static func getRandomColor() -> Color {
        let chance = Int.random(in: 1...100)
        if chance <= 65 {
            return generateRandomColor()
        } else {
            return Color(hex: randomColors.randomElement()!)
        }
    }
    
    private static func generateRandomColor() -> Color {
        let red = Double.random(in: 0.25...0.65)
        let green = Double.random(in: 0.25...0.65)
        let blue = Double.random(in: 0.25...0.65)
        return Color(red: red, green: green, blue: blue)
    }
}
