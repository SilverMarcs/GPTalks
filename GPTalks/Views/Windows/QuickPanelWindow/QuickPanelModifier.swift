//
//  QuickPanelModifier.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/11/2024.
//

#if os(macOS)
import SwiftUI
import KeyboardShortcuts

struct QuickPanelModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var showAdditionalContent: Bool
    @Environment(ChatVM.self) var chatVM
    @Environment(SettingsVM.self) var settingsVM
    @Environment(\.modelContext) var modelContext
    
    func body(content: Content) -> some View {
        content
            .task {
                KeyboardShortcuts.onKeyDown(for: .togglePanel) {
                    isPresented.toggle()
                    QuickPanelTip().invalidate(reason: .actionPerformed)
                }
            }
            .floatingPanel(isPresented: $isPresented, showAdditionalContent: $showAdditionalContent) {
                QuickPanelLoader(isPresented: $isPresented, showAdditionalContent: $showAdditionalContent)
                    .environment(\.isQuick, true)
                    .environment(chatVM)
                    .environment(settingsVM)
                    .modelContainer(modelContext.container)
            }
    }
}

extension View {
    func withFloatingPanel(isPresented: Binding<Bool>, showAdditionalContent: Binding<Bool>) -> some View {
        self.modifier(QuickPanelModifier(isPresented: isPresented, showAdditionalContent: showAdditionalContent))
    }
}
#endif
