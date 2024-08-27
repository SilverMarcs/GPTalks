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
    
    @State private var session: Session?
    @Binding var showAdditionalContent: Bool
    
    var body: some View {
        if let session = session {
            QuickPanel(session: session, showAdditionalContent: $showAdditionalContent)
        } else {
            Text("Something went wrong")
            .padding()
            .onAppear {
                fetchQuickSession()
            }
        }
    }
    
    private func fetchQuickSession() {
        var descriptor = FetchDescriptor<Session>(
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

private struct IsQuickKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isQuick: Bool {
        get { self[IsQuickKey.self] }
        set { self[IsQuickKey.self] = newValue }
    }
}
