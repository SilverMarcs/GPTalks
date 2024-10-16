//
//  ChatInspector.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI
import SwiftData

struct ChatInspector: View {
    @Environment(\.dismiss) var dismiss
    var session: ChatSession
    
    @State private var selectedTab: Tab = .basic
    
    var body: some View {
        #if os(macOS)
        macos
            .frame(height: 625)
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
    
    var commonParts: some View {
        Group {
            switch selectedTab {
            case .basic:
                BasicChatInspector(session: session)
            case .advanced:
                AdvancedChatInspector(session: session)
            }
        }
    }
    
    var picker: some View {
        Picker("Tab", selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Text(tab.rawValue)
            }
        }
        .fixedSize()
        .pickerStyle(.segmented)
        .labelsHidden()
    }
    
    enum Tab: String, CaseIterable {
        case basic = "Basic"
        case advanced = "Advanced"
    }
}


#Preview {
    ChatInspector(session: .mockChatSession)
        .frame(width: 400, height: 700)
}
