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
        
        return textField
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        nsView.stringValue = text
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        let binding: Binding<String>
        
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


#Preview {
    CustomSearchField("Hi", text: .constant(""), height: 30)
}
#endif
