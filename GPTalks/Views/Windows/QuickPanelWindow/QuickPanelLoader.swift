//
//  QuickPanelLoader.swift
//  GPTalks
//
//  Created by Zabir Raihan on 28/07/2024.
//
import SwiftUI
import SwiftData

#if os(macOS)
struct QuickPanelLoader: View {
    @Environment(\.modelContext) var modelContext
    
    @State private var chat: Chat?
    
    var body: some View {
        if let chat = chat {
            QuickPanelView(chat: chat)
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
        let statusId = ChatStatus.quick.id
        
        var descriptor = FetchDescriptor<Chat>(
            predicate: #Predicate { $0.statusId == statusId }
        )
        
        descriptor.fetchLimit = 1
        
        do {
            let quickSessions = try modelContext.fetch(descriptor)
            chat = quickSessions.first
        } catch {
            print("Error fetching quick session: \(error)")
        }
    }
}
#endif
