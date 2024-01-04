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


// Visual effect est la pour rendre le fond effet transparent
struct VisualEffect: NSViewRepresentable {

  func makeNSView(context: Self.Context) -> NSView {
      let test = NSVisualEffectView()
      test.state = NSVisualEffectView.State.active  // this is this state which says transparent all of the time
      return test }

  func updateNSView(_ nsView: NSView, context: Context) { }
}
