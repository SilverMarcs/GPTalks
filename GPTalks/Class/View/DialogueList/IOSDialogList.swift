//
//  IOSDialogList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

#if os(iOS)
    import SwiftUI

    struct IOSDialogList: View {
//        @EnvironmentObject var viewModel: DialogueViewModel
        @Bindable var viewModel: DialogueViewModel
        
        @State var isShowSettingView = false

        var body: some View {
            list
                .listStyle(.inset)
//                .searchable(text: $viewModel.searchText)
                .navigationTitle("Sessions")
                .sheet(isPresented: $isShowSettingView) {
                    IosSettingsView()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isShowSettingView = true
                        } label: {
                            if isIPadOS {
                                Image(systemName: "gear")
                            } else {
                                Text("Config")
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
            if viewModel.dialogues.isEmpty {
                PlaceHolderView(imageName: "message.fill", title: "No Messages Yet")
            } else {
                List(viewModel.dialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
                    DialogueListItem(session: session)
                }
            }
        }

        private var isIPadOS: Bool {
            UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.systemName == "iPadOS"
        }
    }
#endif
