//
//  ContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: DialogueViewModel

    var body: some View {
        NavigationSplitView {
            DialogueSessionListView()
        } detail: {
            if let selectedDialogue = viewModel.selectedDialogue {
                MessageListView(session: selectedDialogue)
            } else {
                Text("No Chat Selected")
                    .font(.title)
            }
        }
        .background(.background)
        .accentColor(viewModel.selectedDialogue?.configuration.provider.accentColor ?? .accentColor)
        .task {
            viewModel.fetchDialogueData()
        }
    }
}
