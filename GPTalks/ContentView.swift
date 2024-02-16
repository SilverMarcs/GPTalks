//
//  ContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(DialogueViewModel.self) private var viewModel
    @State var generations: [ImageObject] = []

    var body: some View {
        NavigationSplitView {
            #if os(macOS)
                MacOSDialogList(viewModel: viewModel)
            #else
                IOSDialogList(viewModel: viewModel)
            #endif
        } detail: {
            if let selectedDialogue = viewModel.selectedDialogue {
                #if os(macOS)
                if viewModel.selectedState == .images {
                    ImageCreator(generations: $generations)
                } else {
                    MacOSMessages(session: selectedDialogue)
                        .frame(minWidth: 500)
                }
                #else

                iOSMessages(session: selectedDialogue)

                #endif
            } else {
                Text("No Chat Selected")
                    .font(.title)
            }
        }
        .background(.background)
        .task {
            viewModel.fetchDialogueData()
        }
    }
}
