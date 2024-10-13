//
//  PasteHandler.swift
//  GPTalks
//
//  Created by Zabir Raihan on 12/10/2024.
//

#if os(macOS)
import SwiftUI
import UniformTypeIdentifiers

struct PasteHandler: ViewModifier {
    @State private var eventMonitor: Any?
    @Environment(ChatSessionVM.self) private var sessionVM

    func body(content: Content) -> some View {
        content
            .onAppear {
                self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
                        if handleCommandV() {
                            return nil // Consume the event if we handled it
                        }
                    }
                    return event
                }
            }
            .onDisappear {
                if let monitor = self.eventMonitor {
                    NSEvent.removeMonitor(monitor)
                }
            }
    }

    private func handleCommandV() -> Bool {
        let pasteboard = NSPasteboard.general
        guard let pasteboardItems = pasteboard.pasteboardItems,
              let session = sessionVM.activeSession else {
            return false
        }

        var handledFiles = false
        var containsText = false

        for item in pasteboardItems {
            if let _ = item.data(forType: .fileURL) {
                session.inputManager.handlePaste(pasteboardItem: item)
                handledFiles = true
            } else if item.types.contains(.png) || item.types.contains(.tiff) {
                session.inputManager.handlePaste(pasteboardItem: item)
                handledFiles = true
            } else if item.types.contains(.string) {
                containsText = true
            }
        }

        if handledFiles {
            return true // We handled at least one file
        } else if containsText {
            // Text in clipboard, let default behavior occur
            return false
        }

        return false // If we didn't handle anything, return false
    }
}

extension View {
    func pasteHandler() -> some View {
        self.modifier(PasteHandler())
    }
}
#endif
