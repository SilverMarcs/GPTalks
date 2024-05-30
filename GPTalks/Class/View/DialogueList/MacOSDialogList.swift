//
//  MacOSDialogList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

struct MacOSDialogList: View {
    @Bindable var viewModel: DialogueViewModel
    @State private var previousActiveDialoguesCount = 0

    var body: some View {
        Group {
            if viewModel.shouldShowPlaceholder {
                PlaceHolderView(imageName: "message.fill", title: viewModel.placeHolderText)
            } else {
                ScrollViewReader { proxy in
                    List(viewModel.currentDialogues, id: \.self, selection: $viewModel.selectedDialogues) { session in
                        DialogueListItem(session: session)
                            .id(session.id.uuidString)
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(Color.gray.opacity(0.2))
                            .accentColor(.accentColor)
                    }
                    .accentColor(Color("niceColorLighter"))
                    .animation(.default, value: viewModel.searchText)
                    .padding(.top, -8)
                    .onChange(of: viewModel.currentDialogues.count) {
                        if viewModel.currentDialogues.count > previousActiveDialoguesCount {
                            if !viewModel.currentDialogues.isEmpty {
                                withAnimation {
                                    proxy.scrollTo(viewModel.currentDialogues[0].id.uuidString, anchor: .top)
                                }
                            }
                        }
                        previousActiveDialoguesCount = viewModel.currentDialogues.count
                    }
                    .onChange(of: viewModel.currentDialogues.first?.date) {
                        if !viewModel.currentDialogues.isEmpty {
                            withAnimation {
                                proxy.scrollTo(viewModel.currentDialogues[0].id.uuidString, anchor: .top)
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
            
            Button("h") {
                viewModel.deleteSelectedDialogues()
            }
            .keyboardShortcut(.delete, modifiers: .command)
            .hidden()
            .disabled(viewModel.selectedDialogues.count < 2)
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .searchable(text: $viewModel.searchText, placement: .toolbar)
    }
}
