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
        Group {
#if os(macOS)
            NavigationSplitView {
                DialogueSessionListView()
            }  detail: {
                Text("Select a Chat to see it here")
                    .font(.title)
            }
            .background(.background)
#else
            NavigationStack {
                DialogueSessionListView()
            }
            .accentColor(viewModel.selectedDialogue?.configuration.provider.accentColor ?? .accentColor)
#endif
        }
        .onAppear {
            viewModel.fetchDialogueData()
        }
    }
}
