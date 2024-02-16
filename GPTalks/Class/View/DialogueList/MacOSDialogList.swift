//
//  MacOSDialogList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI
import OpenAI

struct MacOSDialogList: View {
    @Bindable var viewModel: DialogueViewModel
    @State var images: [ImageObject] = []

    var body: some View {
        Group {
            if viewModel.shouldShowPlaceholder {
                PlaceHolderView(imageName: "message.fill", title: "No Messages Yet")
            } else {
                ScrollViewReader { proxy in
                    List(viewModel.currentDialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
                        DialogueListItem(session: session)
                            .id(session.id)
                            .listRowSeparator(.hidden)
                    }
                    .animation(.default, value: viewModel.isArchivedSelected)
                    .padding(.top, -10)
                    .onChange(of: viewModel.activeDialogues.count) {
//                         this is faaar from perfect but is required if we ant to keep list style inset which is required for animations
//                        if !viewModel.isArchivedSelected {
                            if !viewModel.activeDialogues.isEmpty {
                                proxy.scrollTo(viewModel.activeDialogues[0].id, anchor: .top)
                            }
//                        } p
                    }
                }
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .frame(minWidth: 280)
        .toolbar {
//            Spacer()

            Picker("Archived", selection: $viewModel.isArchivedSelected) {
                Text("Archived").tag(true) // Archived
                Text("Active").tag(false) // Active
            }
            
            Spacer()
            
            Button {
                viewModel.addDialogue()
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .keyboardShortcut("n", modifiers: .command)
        }
    }
}
