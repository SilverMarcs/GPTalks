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
    
    @Query var providers: [Provider]
    @Query(filter: #Predicate<Session> { session in
            session.isQuick == true
    }) var sessions: [Session]
    
    @State private var session: Session?
    @Binding var showAdditionalContent: Bool
    
    let dismiss: () -> Void
    
    var body: some View {
        if let session = session {
            QuickPanel(session: session, showAdditionalContent: $showAdditionalContent, dismiss: dismiss)
        } else {
            Text("Loading...")
                .onAppear {
                    if session == nil {
                        session = sessions.first ?? sessionVM.addQuickItem(providers: providers, modelContext: modelContext)
                    }
                }
        }
    }
}
#endif
