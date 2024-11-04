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
    
    @State private var session: ChatSession?
    @Binding var isPresented: Bool
    @Binding var showAdditionalContent: Bool
    
    var body: some View {
        if let session = session {
            QuickPanel(session: session, isPresented: $isPresented, showAdditionalContent: $showAdditionalContent)
        } else {
            Text("Something went wrong")
                .font(.title)
            .padding()
            .frame(minHeight: 57)
            .task {
                fetchQuickSession()
            }
        }
    }
    
    private func fetchQuickSession() {
        var descriptor = FetchDescriptor<ChatSession>(
            predicate: #Predicate { $0.isQuick == true }
        )
        
        descriptor.fetchLimit = 1
        
        do {
            let quickSessions = try modelContext.fetch(descriptor)
            session = quickSessions.first
        } catch {
            print("Error fetching quick session: \(error)")
        }
    }
}
#endif
