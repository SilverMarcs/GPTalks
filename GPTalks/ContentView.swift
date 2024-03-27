//
//  ContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import CoreData
import SwiftSoup
import SwiftUI

struct ContentView: View {
    @Environment(DialogueViewModel.self) private var viewModel
    @State var imageSession: ImageSession = .init()
    @State var transcriptionSession: TranscriptionSession = .init()

    @State private var isLoading = true
    
    var body: some View {
#if os(macOS)
        NavigationSplitView {
            MacOSDialogList(viewModel: viewModel)
        } detail: {
            if let selectedDialogue = viewModel.selectedDialogue {
                if viewModel.selectedState == .images {
                    ImageCreator(imageSession: imageSession)
                        .onChange(of: viewModel.selectedDialogue) {
                            viewModel.selectedState = .recent
                        }
                } else if viewModel.selectedState == .speech {
                    TranscriptionCreator()
                } else {
                    MacOSMessages(session: selectedDialogue)
//                        .id(selectedDialogue.id)
                        .frame(minWidth: 500)
                }
            } else {
                Text("No Chat Selected")
                    .font(.title)
            }
        }
        .background(.background)
        .task {
            viewModel.fetchDialogueData()
        }
#else

        if isIPadOS {
            NavigationSplitView {
                IOSDialogList(viewModel: viewModel)
            } detail: {
                if let selectedDialogue = viewModel.selectedDialogue {
                    iOSMessages(session: selectedDialogue)
                        .id(selectedDialogue.id)
                } else {
                    Text("No Chat Selected")
                        .font(.title)
                }
            }
        } else {
            NavigationStack {
                IOSDialogList(viewModel: viewModel)
            }
            .task {
                viewModel.fetchDialogueData()
            }
        }
#endif
    }
}
