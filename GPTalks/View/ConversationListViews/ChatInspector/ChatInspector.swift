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
    @Binding var showingInspector: Bool
    
    @State private var selectedTab: Tab = .basic
    
    var body: some View {
        NavigationStack {
            Group {
                switch selectedTab {
                case .basic:
                    BasicChatInspector(session: session)
                case .advanced:
                    AdvancedChatInspector(session: session)
                }
            }
            #if os(macOS)
            .scrollDisabled(true)
            #endif
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    picker
                }
                
                ToolbarItem {
                    Button {
                        showingInspector.toggle()
                    } label: {
                        #if os(macOS)
                        Label("Toggle Inspector", systemImage: "sidebar.right")
                        #else
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray, .gray.opacity(0.3))
                        #endif
                    }
                }
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
    let providers: [Provider] = []
    
    ChatInspector(session: ChatSession(config: SessionConfig()), showingInspector: .constant(true))
        .modelContainer(for: Provider.self, inMemory: true)
        .formStyle(.grouped)
        .frame(width: 400, height: 700)
}
