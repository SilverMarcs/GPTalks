//
//  MacOSDialogList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import OpenAI
import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct MacOSDialogList: View {
    @Bindable var viewModel: DialogueViewModel

    var body: some View {
        Group {
            if viewModel.shouldShowPlaceholder {
                PlaceHolderView(imageName: "message.fill", title: viewModel.placeHolderText)
            } else {
                ScrollViewReader { proxy in
                    List(viewModel.currentDialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
                        DialogueListItem(session: session)
                            .id(session.id)
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(Color.gray.opacity(0.2))
                            .accentColor(.accentColor) // to keep row colors untouched
                    }
                    .accentColor(Color("niceColorLighter")) // to change list seldction color
                    .animation(.default, value: viewModel.selectedState)
                    .animation(.default, value: viewModel.searchText)
                    .padding(.top, -8)
                    .onChange(of: viewModel.activeDialogues.count) {
//                         this is faaar from perfect but is required if we want to keep list style inset which is required for animations
                        if !viewModel.activeDialogues.isEmpty {
                            proxy.scrollTo(viewModel.activeDialogues[0].id, anchor: .top)
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
