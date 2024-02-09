//
//  IOSDialogList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

#if os(iOS)
    import SwiftUI
import OpenAI

    struct IOSDialogList: View {
        @Bindable var viewModel: DialogueViewModel
        @State var images: [ImagesResult.URLResult] = []

        @State var isShowSettingView = false

        var body: some View {
            list
                .listStyle(.inset)
                .searchable(text: $viewModel.searchText)
                .navigationTitle("Sessions")
                .sheet(isPresented: $isShowSettingView) {
                    IosSettingsView()
                }
                .toolbar {
//                    ToolbarItem {
//                        NavigationLink {
//                            ImageSession(images: $images)
//                        } label: {
//                            Image(systemName: "photo.on.rectangle.angled")
//                        }
//                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            Button {
                                viewModel.toggleArchivedStatus()
                            } label: {
                                Label(
                                    title: { Text(viewModel.isArchivedSelected ? "Active Chats" : "Archived Chats") },
                                    icon: { Image(systemName: viewModel.isArchivedSelected ? "archivebox.fill" : "archivebox") }
                                )
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
                                Text("Edit")
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
