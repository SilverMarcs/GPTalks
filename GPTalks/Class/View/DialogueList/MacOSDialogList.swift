//
//  MacOSDialogList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

struct MacOSDialogList: View {
    @Bindable var viewModel: DialogueViewModel
    @State private var previousActiveDialoguesCount = 0 // Add this line

    var body: some View {
        Group {
            if viewModel.shouldShowPlaceholder {
                PlaceHolderView(imageName: "message.fill", title: viewModel.placeHolderText)
            } else {
                ScrollViewReader { proxy in
                    List(viewModel.currentDialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
                        DialogueListItem(session: session)
//                            .id(session.id)
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(Color.gray.opacity(0.2))
                            .accentColor(.accentColor) // to keep row colors untouched
                    }
                    .accentColor(Color("niceColorLighter")) // to change list selection color
                    .animation(.default, value: viewModel.selectedState)
                    .animation(.default, value: viewModel.searchText)
                    .padding(.top, -8)
                    .onChange(of: viewModel.currentDialogues.count) {
                        // Check if the current count is greater than the previous count
                        if viewModel.currentDialogues.count > previousActiveDialoguesCount {
                            // If so, it's an addition. Scroll to the first item.
                            if !viewModel.currentDialogues.isEmpty {
                                withAnimation {
                                    proxy.scrollTo(viewModel.currentDialogues[0].id, anchor: .top)
                                }
                            }
                        }
                        // Update the previous count to the current count
                        previousActiveDialoguesCount = viewModel.currentDialogues.count
                    }
                    .onChange(of: viewModel.currentDialogues.first?.date) {
                        if !viewModel.currentDialogues.isEmpty {
                            withAnimation {
                                proxy.scrollTo(viewModel.currentDialogues[0].id, anchor: .top)
                            }
                        }
                    }
                }
            }
        }

        .frame(minWidth: 290)
        .toolbar {
            Spacer()

            Picker("Select State", selection: $viewModel.selectedState) {
                ForEach(ContentState.allCases) { state in
                    Text(state.rawValue).tag(state)
                }
            }

            Spacer()

            Button {
                viewModel.addDialogue()
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .keyboardShortcut("n", modifiers: .command)
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .searchable(text: $viewModel.searchText, placement: .toolbar)
    }
}
