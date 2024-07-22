//
//  InspectorView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct InspectorView: View {
    @Environment(SessionVM.self) private var sessionVM
    @Binding var showingInspector: Bool
    
    var body: some View {
        Group {
            switch sessionVM.state {
            case .chats:
                if sessionVM.selections.count == 1, let first = sessionVM.selections.first {
                    ChatInspector(session: first)
                }
            case .images:
                if sessionVM.imageSelections.count == 1, let first = sessionVM.imageSelections.first {
                    ImageInspector(session: first)
                }
            }
        }
        .inspectorColumnWidth(min: 245, ideal: 265, max: 300)
        .toolbar {
            if showingInspector, sessionVM.state == .chats, sessionVM.selections.count == 1, let first = sessionVM.selections.first {
                Text("Tokens: " + first.tokenCounter.formatToK()).foregroundStyle(.secondary)
                
                Spacer()
            }
            
            if showingInspector, sessionVM.state == .images {
                Text("Config").foregroundStyle(.secondary)
                
                Spacer()
            }
                
            #if os(macOS)
            Button {
                showingInspector.toggle()
            } label: {
                Label("Inspector", systemImage: "info.circle")
            }
            #endif
        }
    }
}

#Preview {
    InspectorView(showingInspector: .constant(true))
        .environment(SessionVM())
}
