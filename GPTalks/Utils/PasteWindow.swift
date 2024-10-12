//
//  PasteWindow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/10/2024.
//

import SwiftUI

class PasteWindow: NSWindow {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
            print("Command-V")
            let pasteboard = NSPasteboard.general
            guard let pasteboardItems = pasteboard.pasteboardItems else {
                return false
            }
            
            for item in pasteboardItems {
                if let fileURLData = item.data(forType: .fileURL),
                   let fileURL = URL(dataRepresentation: fileURLData, relativeTo: nil) {
                    print("File detected in clipboard")
                    print(fileURL)
                    return true
                } else if let text = item.data(forType: .string) {
                    return false
                }
            }
        }
        return super.performKeyEquivalent(with: event)
    }
}

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                let customWindow = CustomWindow(contentRect: window.frame,
                                                styleMask: window.styleMask,
                                                backing: .buffered,
                                                defer: false)
                customWindow.contentView = window.contentView
                window.close()
                customWindow.makeKeyAndOrderFront(nil)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
