//
//  SessionSearch.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

#if os(macOS)
import SwiftUI

struct CustomSearchField: NSViewRepresentable {
    @Binding var text: String
    let prompt: String
    let height: CGFloat
    let showFocusRing: Bool
    
    init(_ prompt: String, text: Binding<String>, height: CGFloat = 30, showFocusRing: Bool = false) {
        self.prompt = prompt
        self.height = height
        self.showFocusRing = showFocusRing
        _text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(binding: $text)
    }
    
    func makeNSView(context: Context) -> NSSearchField {
        let textField = NSSearchField(string: text)
        textField.placeholderString = prompt
        textField.delegate = context.coordinator
        textField.bezelStyle = .roundedBezel
        if !showFocusRing {
            textField.focusRingType = .none
        }
        
        // Set the height constraint
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: height)
        ])
        
        // Add keyboard shortcut listener
//        let shortcutListener = ShortcutListener(searchField: textField, binding: $text)
//        context.coordinator.shortcutListener = shortcutListener
//        shortcutListener.startListening()
        
        return textField
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        nsView.stringValue = text
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        let binding: Binding<String>
//        var shortcutListener: ShortcutListener?
        
        init(binding: Binding<String>) {
            self.binding = binding
            super.init()
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            binding.wrappedValue = field.stringValue
        }
    }
}

//class ShortcutListener {
//    weak var searchField: NSSearchField?
//    var binding: Binding<String>
//    
//    init(searchField: NSSearchField, binding: Binding<String>) {
//        self.searchField = searchField
//        self.binding = binding
//    }
//    
//    func startListening() {
//        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
//            guard let self = self else { return event }
//            
//            if event.modifierFlags.contains(.command) && event.characters == "f" {
//                self.searchField?.becomeFirstResponder()
//                return nil
//            }
//            
//            if event.keyCode == 53, self.searchField?.window?.firstResponder == self.searchField {
//                // 53 is the key code for the escape key
//                self.searchField?.window?.makeFirstResponder(nil) // Lose focus
//                self.binding.wrappedValue = "" // Clear the text
//                return nil
//            }
//            
//            return event
//        }
//    }
//}


//#Preview {
//    CustomSearchField("Hi", text: .constant(""), height: 30)
//}
#endif
