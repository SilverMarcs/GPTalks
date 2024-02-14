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
            if viewModel.dialogues.isEmpty {
                PlaceHolderView(imageName: "message.fill", title: "No Messages Yet")
            } else {
                ScrollViewReader { proxy in
                    List(viewModel.dialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
                        DialogueListItem(session: session)
                            .id(session.id)
                            .listRowSeparator(.hidden)
                    }
                    .padding(.top, -10)
                    .onChange(of: viewModel.dialogues.count) {
                        // this is faaar from perfect but is required if we ant to keep list style inset which is required for animations
                        proxy.scrollTo(viewModel.dialogues[0].id, anchor: .top)
                    }
                }
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .frame(minWidth: 270)
        .toolbar {
            Spacer()

            NavigationLink {
                ImageCreator(generations: $images)
            } label: {
                Image(systemName: "photo")
            }

            Button {
                viewModel.addDialogue()
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .keyboardShortcut("n", modifiers: .command)
        }
    }
}
