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
    @State var imageSession: ImageSession = .init()
    @State var navigateToImages = false

    @State var isShowSettingView = false

    var body: some View {
        list
            .fullScreenCover(isPresented: $navigateToImages, onDismiss: {navigateToImages = false}) {
                NavigationStack {
                    ImageCreator(imageSession: imageSession)
                }
            }
            .animation(.default, value: viewModel.selectedState)
            .animation(.default, value: viewModel.searchText)
            .searchable(text: $viewModel.searchText)
        #if os(iOS)
//                .navigationTitle("Sessions")
            .navigationTitle(viewModel.selectedState.rawValue)
        #endif
            .sheet(isPresented: $isShowSettingView) {
                IosSettingsView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                  Menu {
                      Picker("Select State", selection: $viewModel.selectedState) {
                          ForEach(ContentState.allCases) { state in
                              Label("\(state.rawValue)", systemImage: state.image)
                                  .tag(state)
                          }
                      }
                      .onChange(of: viewModel.selectedState) {
                          if viewModel.selectedState == .images {
                              navigateToImages = true
                          }
                      }
                      .onChange(of: navigateToImages) {
                          viewModel.selectedState = .chats
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
//                if isIPadOS {
                    List(viewModel.currentDialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
                        DialogueListItem(session: session)
                    }
                    .listStyle(.plain)
//                } else {
//                    List(viewModel.currentDialogues, id: \.self) { session in
//                        NavigationLink {
//                            iOSMessages(session: session)
//                                .id(session.id)
//                        } label: {
//                            DialogueListItem(session: session)
//                        }
//                    }
//                    .listStyle(.plain)
//                }
            }
    }
}
#endif
