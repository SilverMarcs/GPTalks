//
//  QuickPanelHelper.swift
//  GPTalks
//
//  Created by Zabir Raihan on 28/07/2024.
//
import SwiftUI
import SwiftData

#if os(macOS)
struct QuickPanelHelper: View {
    @Environment(\.modelContext) var modelContext
    @Environment(SessionVM.self) var sessionVM
    
    @Query(filter: #Predicate { $0.isEnabled }, sort: [SortDescriptor(\Provider.order, order: .forward)], animation: .default)
    var providers: [Provider]
    @Query(filter: #Predicate<Session> { session in
            session.isQuick == true
    }) var sessions: [Session]
    
    @State private var session: Session?
    @Binding var showAdditionalContent: Bool
    
    var body: some View {
        if let session = session {
            QuickPanel(session: session, showAdditionalContent: $showAdditionalContent)
        } else {
//            Group {
//                if sessions.isEmpty {
//                    Button("Add Quick Session. Restart app to use it.") {
//                        sessionVM.addQuickItem(providers: providers, modelContext: modelContext)
//                        clicked = true
//                    }
//                } else {
//                    Text("Restart manually")
//                }
//            }
            Button("Add Quick Session. This will quit the app. Pleaase Restart it manually") {
                sessionVM.addQuickItem(providers: providers, modelContext: modelContext)
                // quit the app
                NSApplication.shared.terminate(self)
            }
            .padding()
            .onAppear {
                session = sessions.first
            }
        }
    }
}
#endif
