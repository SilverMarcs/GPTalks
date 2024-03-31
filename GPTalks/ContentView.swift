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
    @Environment(\.scenePhase) var scenePhase
    
    @State var imageSession: ImageSession = .init()
    @State var transcriptionSession: TranscriptionSession = .init()
    
    @State var resumed: Bool = false
    
    var body: some View {
#if os(macOS)
        NavigationSplitView {
            MacOSDialogList(viewModel: viewModel)
        } detail: {
            if viewModel.selectedState == .images {
                ImageCreator(imageSession: imageSession)
            } else if viewModel.selectedState == .speech {
                TranscriptionCreator()
            } else {
                if let selectedDialogue = viewModel.selectedDialogue {
                    MacOSMessages(session: selectedDialogue)
                        .frame(minWidth: 500)
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
                    if let first = viewModel.currentDialogues.first, viewModel.selectedDialogue == nil {
                        NavigationLink(destination: iOSMessages(session: first, isAutoResuming: true), isActive: $resumed) {
//                            iOSMessages(session: first).isTextFieldFocused = true
                        }
                    }
                    
                    IOSDialogList(viewModel: viewModel)
                }
                .task {
                    viewModel.fetchDialogueData()
                }
            }
        }
        .onChange(of: scenePhase) {
           switch scenePhase {
           case .active:
               print("App has resumed from background")
               if AppConfiguration.shared.autoResume {
                   resumed = true
               }
           case .inactive, .background:
               break
           @unknown default:
               break
           }
       }
#endif
    }
}
