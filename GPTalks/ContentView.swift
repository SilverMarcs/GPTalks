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
    @ObservedObject var config = AppConfiguration.shared
    
    @State var imageSession: ImageSession = .init()
    
    @State var showAlert = false
    
    var body: some View {
#if os(macOS)
        NavigationSplitView {
            MacOSDialogList(viewModel: viewModel)
                .onAppear {
                    if config.OAIkey.isEmpty {
                        showAlert.toggle()
                    }
                }
                .alert("Enter OpenAI API Key", isPresented: $showAlert) {
                    TextField("API Key", text: $config.OAIkey)
                    Button("Cancel", role: .cancel) {}
                    Button("OK") {}
                }
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
#else
        NavigationSplitView {
            IOSDialogList(viewModel: viewModel)
                .onAppear {
                    if config.OAIkey.isEmpty {
                        showAlert.toggle()
                    }
                }
                .alert("Enter OpenAI API Key", isPresented: $showAlert) {
                    TextField("API Key", text: $config.OAIkey)
                    Button("Cancel", role: .cancel) {}
                    Button("OK") {}
                }
                .onChange(of: scenePhase) {
                   switch scenePhase {
                   case .active:
                       if viewModel.selectedDialogue == nil {
                           withAnimation {
                               if let first = viewModel.allDialogues.first, first.conversations.isEmpty {
                                   viewModel.selectedDialogue = viewModel.allDialogues.first
                               } else {
                                   viewModel.addDialogue()
                               }
                           }
                       }
                   case .inactive, .background:
                       break
                   @unknown default:
                       break
                   }
               }
        } detail: {
            if let selectedDialogue = viewModel.selectedDialogue {
                iOSMessages(session: selectedDialogue)
                    .id(selectedDialogue.id)
            } else {
                Text("No Chat Selected")
                    .font(.title)
            }
        }
#endif
    }
}
