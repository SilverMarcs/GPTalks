//
//  MacOSDialogList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

struct MacOSDialogList: View {
    @EnvironmentObject var viewModel: DialogueViewModel
    
    var body: some View {
        Group {
            if viewModel.dialogues.isEmpty {
                PlaceHolderView(imageName: "message.fill", title: "No Messages Yet")
            } else {
                List(viewModel.isArchivedSelected ? viewModel.archivedDialogues : viewModel.dialogues , id: \.self, selection: $viewModel.selectedDialogue) { session in
                    DialogueListItem(session: session)
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 270)
        .toolbar {
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
