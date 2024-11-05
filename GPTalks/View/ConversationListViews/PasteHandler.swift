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
    @Environment(ChatVM.self) private var sessionVM

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
        guard let pasteboardItems = NSPasteboard.general.pasteboardItems,
              let session = sessionVM.activeChat else {
            return false
        }

        let handledTypes: Set<NSPasteboard.PasteboardType> = [.fileURL, .png, .tiff, .pdf]
        var handledFiles = false
        var containsText = false

        for item in pasteboardItems {
            if Set(item.types).intersection(handledTypes).isEmpty == false {
                session.inputManager.handlePaste(pasteboardItem: item)
                handledFiles = true
            } else if item.types.contains(.string) {
                containsText = true
            }
        }

        return handledFiles || (containsText ? false : false)
    }
}

extension View {
    func pasteHandler() -> some View {
        self.modifier(PasteHandler())
    }
}
#endif
