//
//  ContentView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(DialogueViewModel.self) private var viewModel
    @Environment(\.scenePhase) var scenePhase
    
    @State var imageSession: ImageSession = .init()
    @State var transcriptionSession: TranscriptionSession = .init()
    
    var body: some View {
#if os(macOS)
        NavigationSplitView {
            MacOSDialogList(viewModel: viewModel)
        } detail: {
            if viewModel.selectedState == .images {
                ImageCreator(imageSession: imageSession)
                    .onChange(of: viewModel.selectedDialogues) {
                        if viewModel.selectedDialogues.count == 1 {
                            viewModel.selectedState = .chats
                        }
                    }
            } else if viewModel.selectedState == .chats {
                if viewModel.selectedDialogues.count > 1 {
                    Text("\(viewModel.selectedDialogues.count) Chats Selected")
                        .font(.title)
                } else if viewModel.selectedDialogues.count == 1 {
                    if let selectedDialogue = viewModel.selectedDialogues.first {
                        MacOSMessages(session: selectedDialogue)
                            .id(selectedDialogue.id)
                            .frame(minWidth: 500, minHeight: 500)
                    }
                } else {
                    Text("No Chat Selected")
                        .font(.title)
                }
            }
        }
        .background(.background)
        .task {
            viewModel.fetchDialogueData()
        }
#else
        Group {
            if isIPadOS {
                NavigationSplitView {
                    IOSDialogList(viewModel: viewModel)
                } detail: {
                    if let selectedDialogue = viewModel.selectedDialogues.first {
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
        }
#endif
    }
}
