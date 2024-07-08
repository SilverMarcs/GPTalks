//
//  ColorExtensions.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/07/2024.
//

import SwiftUI

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
}


#Preview {
//    let session = Session()
    
    Color(hex: "FF0000FF")
    
    Text(Color(hex: "FF0000FF").toHex())
    
//    SessionListItem(session: session)
//        .frame(width: 230)
//        .modelContainer(for: Session.self, inMemory: true)
//        .environment(SessionVM())
}