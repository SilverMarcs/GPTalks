//
//  SessionSearch.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

#if os(macOS)
import SwiftUI

struct SessionSearch: NSViewRepresentable {
    @Binding var text: String
    var onClear: () -> Void
    let prompt: String
    let height: CGFloat
    
    init(_ prompt: String, text: Binding<String>, height: CGFloat = 30, onClear: @escaping () -> Void) {
        self.onClear = onClear
        self.prompt = prompt
        self.height = height
        _text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(binding: $text, onClear: onClear)
    }
    
    func makeNSView(context: Context) -> NSSearchField {
        let textField = NSSearchField(string: text)
        textField.placeholderString = prompt
        textField.delegate = context.coordinator
        textField.bezelStyle = .roundedBezel
        textField.focusRingType = .none
        
        // Set the height constraint
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: height)
        ])
        
        // Add keyboard shortcut listener
        let shortcutListener = ShortcutListener(searchField: textField)
        context.coordinator.shortcutListener = shortcutListener
        shortcutListener.startListening()
        
        return textField
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        nsView.stringValue = text
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        let binding: Binding<String>
        let onClear: () -> Void
        var shortcutListener: ShortcutListener?
        
        init(binding: Binding<String>, onClear: @escaping () -> Void) {
            self.binding = binding
            self.onClear = onClear
            super.init()
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            binding.wrappedValue = field.stringValue
            
            if field.stringValue.isEmpty {
                onClear()
            }
        }
    }
}

class ShortcutListener {
    weak var searchField: NSSearchField?
    
    init(searchField: NSSearchField) {
        self.searchField = searchField
    }
    
    func startListening() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            if event.modifierFlags.contains(.command) && event.characters == "f" {
                self.searchField?.becomeFirstResponder()
                return nil
            }
            return event
        }
    }
}

#Preview {
    SessionSearch("Hi", text: .constant(""), height: 30) {
        print("Clear")
    }
}
#endif
