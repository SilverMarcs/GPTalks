//
//  InputEditor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI
#if !os(macOS) && !targetEnvironment(macCatalyst) && !os(visionOS)
import VisualEffectView
#endif

struct InputEditor: View {
    @Binding var prompt: String
    var provider: Provider
    @FocusState var isFocused: Bool
    
    var body: some View {
        #if os(iOS)
        iOSInputEditor(prompt: $prompt, provider: provider, isFocused: _isFocused)
        #else
        MacInputEditor(prompt: $prompt, provider: provider, isFocused: _isFocused)
        #endif
    }
}


struct iOSInputEditor: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var prompt: String
    var provider: Provider
    @FocusState var isFocused: Bool
    
    @State private var showPopover: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TextField(placeHolder, text: $prompt, axis: .vertical)
                .focused($isFocused)
                .padding(6)
                .padding(.leading, 15)
                .lineLimit(10)
                .modifier(RoundedRectangleOverlayModifier(radius: 18))
            #if !os(macOS) && !targetEnvironment(macCatalyst) && !os(visionOS)
                .background(
                    VisualEffect(colorTint: colorScheme == .dark
                                 ? Color(hex: "050505")
                                 : Color(hex: "FAFAFE"),
                                 colorTintAlpha: 0.3, blurRadius: 18, scale: 1)
                    .cornerRadius(6)
                )
            #endif
            
            if prompt.count > 25 {
                ExpandButton(size: 25) { showPopover.toggle() }
                    .padding(5)
                    .sheet(isPresented: $showPopover) {
                        ExpandedTextField(prompt: $prompt)
                    }
            }
        }
    }
    
    var placeHolder: String {
        "Send a prompt • \(provider.name)"
    }
    
    var leadingPadding: CGFloat {
        return 10
    }
}

struct MacInputEditor: View {
    @Binding var prompt: String
    var provider: Provider
    @FocusState var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            if prompt.isEmpty {
                Text(placeHolder)
                    .padding(6)
                    .padding(.leading, 6)
                    .foregroundStyle(.placeholder)
            }
            
            TextEditor(text: $prompt)
                .focused($isFocused)
                .frame(maxHeight: 400)
                .fixedSize(horizontal: false, vertical: true)
                .scrollContentBackground(.hidden)
                .padding(6)
        }
        .font(.body)
        .modifier(RoundedRectangleOverlayModifier(radius: 18))
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button {
                    isFocused = true
                    AppConfig.shared.sidebarFocus = false
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
                .keyboardShortcut("l", modifiers: .command)
            }
        }
        .task {
            if !AppConfig.shared.sidebarFocus {
                isFocused = true
            }
        }
    }
    
    var placeHolder: String {
        "Send a prompt • \(provider.name)"
    }
    
    var leadingPadding: CGFloat {
        return 0
    }
}




//struct InputEditor: View {
//    @Environment(\.colorScheme) var colorScheme
//    
//    @Binding var prompt: String
//    var provider: Provider
//    @FocusState var isFocused: Bool
//    
//    @State var showPopover: Bool = false
//    
//    var body: some View {
//        inputView
//        .font(.body)
//        #if os(macOS) || targetEnvironment(macCatalyst)
//        .task {
//            if !AppConfig.shared.sidebarFocus {
//                isFocused = true
//            }
//        }
//        #endif
//    }
//    
//    #if os(macOS) || targetEnvironment(macCatalyst)
//    @ViewBuilder
//    var inputView: some View {
//        ZStack(alignment: .leading) {
//            if prompt.isEmpty {
//                Text(placeHolder)
//                    .padding(padding)
//                    .padding(.leading, 6)
//                    .padding(.leading, leadingPadding)
//                    .foregroundStyle(.placeholder)
//            }
//            
//            TextEditor(text: $prompt)
//                .focused($isFocused)
//                .frame(maxHeight: 400)
//                .fixedSize(horizontal: false, vertical: true)
//                .scrollContentBackground(.hidden)
//                .padding(padding)
//                .padding(.leading, leadingPadding)
//        }
//        .modifier(RoundedRectangleOverlayModifier(radius: radius))
//        .toolbar {
//            ToolbarItem(placement: .keyboard) {
//                Button {
//                    isFocused = true
//                    AppConfig.shared.sidebarFocus = false
//                } label: {
//                    Image(systemName: "keyboard.chevron.compact.down")
//                }
//                .keyboardShortcut("l", modifiers: .command)
//            }
//        }
//    }
//    #else
//    var inputView: some View {
//        ZStack(alignment: .bottomTrailing) {
//            TextField(placeHolder, text: $prompt, axis: .vertical)
//                .focused($isFocused)
//                .padding(padding)
//                .padding(.leading, 5)
//                .lineLimit(10)
//                .modifier(RoundedRectangleOverlayModifier(radius: radius))
//                .background(
//                    VisualEffect(colorTint: colorScheme == .dark
//                                 ? Color(hex: "050505")
//                                 : Color(hex: "FAFAFE"),
//                                 colorTintAlpha: 0.3, blurRadius: 18, scale: 1)
//                    .cornerRadius(radius)
//                )
//            
//            if isIOS() && prompt.count > 25 {
//                ExpandButton(size: 25) { showPopover.toggle() }
//                    .padding(5)
//                    .sheet(isPresented: $showPopover) {
//                        ExpandedTextField(prompt: $prompt)
//                    }
//    
//            }
//        }
//    }
//    #endif
//    
//    var placeHolder: String {
//        "Send a prompt • \(provider.name)"
//    }
//
//    var radius: CGFloat {
//        18
//    }
//    
//    var padding: CGFloat {
//        #if os(macOS) || targetEnvironment(macCatalyst)
//        return 6
//        #else
//        return 6
//        #endif
//    }
//    
//    var leadingPadding: CGFloat {
//        #if os(macOS) || targetEnvironment(macCatalyst)
//        return 0
//        #else
//        return 10
//        #endif
//    }
//}
//
#Preview {
    InputEditor(prompt: .constant("Hello, World!"), provider: Provider.factory(type: .openai))
}
