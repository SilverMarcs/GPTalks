//
//  InspectorView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

//struct InspectorView: View {
//    @Environment(SessionVM.self) private var sessionVM
//    @Binding var showingInspector: Bool
//    @State var animate = false
//    
//    var body: some View {
//        NavigationStack {
//            switch sessionVM.state {
//            case .chats:
//                if let first = sessionVM.selections.first, sessionVM.selections.count == 1 {
//                    ChatInspector(session: first)
//                        .id(first.id)
//                }
//            case .images:
//                if let first = sessionVM.imageSelections.first, sessionVM.imageSelections.count == 1 {
//                    ImageInspector(session: first)
//                        .id(first.id)
//                }
//            }
//        }
//        #if !os(macOS)
//        .scrollDismissesKeyboard(.interactively)
//        #endif
//        #if !os(visionOS)
//        .inspectorColumnWidth(min: 245, ideal: 265, max: 300)
//        #endif
//        .toolbar {
//            if let first = sessionVM.selections.first, showingInspector, sessionVM.state == .chats, sessionVM.selections.count == 1 {
//                
//                Text("Tokens: \(first.tokenCount.formatToK())")
//                    .foregroundStyle(.secondary)
//                
//                Spacer()
//            }
//            
//            if showingInspector, sessionVM.state == .images {
//                Text("Config").foregroundStyle(.secondary)
//                
//                Spacer()
//            }
//                
//            #if os(macOS)
//            Spacer()
//            
//            Button {
//                showingInspector.toggle()
//            } label: {
//                Label("Inspector", systemImage: "info.circle")
//            }
//            #endif
//        }
//    }
//}
//
//#Preview {
//    InspectorView(showingInspector: .constant(true))
//        .environment(SessionVM())
//}
