//
//  FloatingPanelModifier.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/11/2024.
//

#if os(macOS)
import SwiftUI
import KeyboardShortcuts

struct FloatingPanelModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var showAdditionalContent: Bool
    @Environment(ChatVM.self) var chatVM
    @Environment(\.modelContext) var modelContext
    
    func body(content: Content) -> some View {
        content
            .task {
                KeyboardShortcuts.onKeyDown(for: .togglePanel) {
                    isPresented.toggle()
                }
            }
            .floatingPanel(isPresented: $isPresented, showAdditionalContent: $showAdditionalContent) {
                QuickPanelLoader(isPresented: $isPresented, showAdditionalContent: $showAdditionalContent)
                    .environment(\.isQuick, true)
                    .environment(chatVM)
                    .modelContainer(modelContext.container)
            }
    }
}

extension View {
    func withFloatingPanel(isPresented: Binding<Bool>, showAdditionalContent: Binding<Bool>) -> some View {
        self.modifier(FloatingPanelModifier(isPresented: isPresented, showAdditionalContent: showAdditionalContent))
    }
}
#endif