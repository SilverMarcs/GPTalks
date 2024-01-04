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
                ScrollViewReader { proxy in
//                    Color.clear
//                        .frame(width: 0, height: 0)
////                        .hidden()
//                        .id("scrollToTop")
                    List(viewModel.isArchivedSelected ? viewModel.archivedDialogues : viewModel.dialogues , id: \.self, selection: $viewModel.selectedDialogue) { session in
                        DialogueListItem(session: session)
                            .listRowSeparator(.hidden)
                    }
                    .padding(.top, -10)
                    .onChange(of: viewModel.dialogues.count) {
//                        withAnimation {
                        print("comes here")
                        DispatchQueue.main.async {
                            proxy.scrollTo("scrollToTop", anchor: .top)
                        }
                    }
                }
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
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

