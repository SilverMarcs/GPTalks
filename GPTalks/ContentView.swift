//
//  ContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DialogueViewModel(context: PersistenceController.shared.container.viewContext)

    var body: some View {
        Group {
#if os(macOS)
            NavigationSplitView {
                DialogueSessionListView()
            }  detail: {
                Text("Select a Chat to see it here")
                    .font(.title)
            }
#else
            NavigationStack {
                DialogueSessionListView()
            }
#endif
        }
        .environmentObject(viewModel)
        .onAppear {
            viewModel.fetchDialogueData()
        }
    }
}
