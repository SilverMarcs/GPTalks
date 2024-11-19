//
//  ChatInspector.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI
import TipKit

struct ChatInspector: View {
    @Environment(\.dismiss) var dismiss
    var chat: Chat
    
    @State private var selectedTab: InspectorTab = .basic
    
    var body: some View {
        #if os(macOS)
        macos
        #else
        ios
        #endif
    }
    
    var macos: some View {
        commonParts
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack {
                    DismissButton()
                        .opacity(0)
                    
                    Spacer()
                    
                    picker
                    
                    Spacer()
                    
                    DismissButton()
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.bar)
            }
    }
    
    var ios: some View {
        NavigationStack {
            commonParts
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        picker
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        DismissButton()
                    }
                }
        }
    }
    
    @ViewBuilder
    var commonParts: some View {
        switch selectedTab {
        case .basic:
            BasicInspector(chat: chat)
        case .advanced:
            AdvancedInspector(chat: chat)
        }
    }
    
    var picker: some View {
        Picker("Tab", selection: $selectedTab) {
            ForEach(InspectorTab.allCases, id: \.self) { tab in
                Text(tab.rawValue)
            }
        }
        .fixedSize()
        .pickerStyle(.segmented)
        .labelsHidden()
        .popoverTip(ChatInspectorToolsTip())
        .onChange(of: selectedTab) {
            if selectedTab == .advanced {
                ChatInspectorToolsTip().invalidate(reason: .actionPerformed)
            }
        }
    }
}


#Preview {
    ChatInspector(chat: .mockChat)
        .frame(width: 400, height: 700)
}
