//
//  IOSDialogList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

#if !os(macOS)
import SwiftUI
import OpenAI

    struct IOSDialogList: View {
        @Bindable var viewModel: DialogueViewModel
        @State var generations: [ImageObject] = []

        @State var isShowSettingView = false

        var body: some View {
            list
                .listStyle(.inset)
                .searchable(text: $viewModel.searchText)
            #if os(iOS)
                .navigationTitle("Sessions")
            #endif
                .sheet(isPresented: $isShowSettingView) {
                    IosSettingsView()
                }
                .toolbar {
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            Picker("Select State", selection: $viewModel.selectedState) {
                                ForEach(ContentState.allCases) { state in
                                    Text(state.rawValue)
                                        .tag(state)
                                }
                            }
                            
                            Button {
                                isShowSettingView = true
                            } label: {
                                Label(
                                    title: { Text("Settings") },
                                    icon: { Image(systemName: "gear") }
                                )
                            }
                            
                        } label: {
                            if isIPadOS {
                                Image(systemName: "gear")
                            } else {
                                Text("More")
                            }
                        }
                    }

                    ToolbarItem(placement: .automatic) {
                        Button {
                            viewModel.addDialogue()
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .keyboardShortcut("n", modifiers: .command)
                    }
                }
        }

        @ViewBuilder
        private var list: some View {
            if viewModel.shouldShowPlaceholder {
                PlaceHolderView(imageName: "message.fill", title: viewModel.placeHolderText)
            } else {
                List(viewModel.currentDialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
                    DialogueListItem(session: session)
                }
            }
        }

        private var isIPadOS: Bool {
            UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.systemName == "iPadOS"
        }
    }
#endif
