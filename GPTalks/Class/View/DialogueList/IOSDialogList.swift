//
//  IOSDialogList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

#if os(iOS)
import SwiftUI

struct IOSDialogList: View {
    @EnvironmentObject var viewModel: DialogueViewModel
    @State var isShowSettingView = false
    
    
    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.systemName == "iPadOS" {
                list
                    .listStyle(.sidebar)
            } else {
                list
                    .listStyle(.plain)
            }
        }

        .searchable(text: $viewModel.searchText)
        .navigationTitle("Sessions")
        .sheet(isPresented: $isShowSettingView) {
            AppSettingsView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isShowSettingView = true
                } label: {
//                    Image(systemName: "gear")
                    Text("Config")
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
            List(viewModel.filteredDialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
                DialogueListItem(session: session)
            }
        }
    }
}
#endif
