//
//  DialogueSessionListView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/11/2024.
//

import CoreData
import SwiftUI

struct DialogueSessionListView: View {
    @EnvironmentObject var viewModel: DialogueViewModel
    @State var isShowSettingView = false

    var body: some View {
        if viewModel.dialogues.isEmpty {
            PlaceHolderView(imageName: "message.fill", title: "No Messages Yet")
        } else {
            Group {
                #if os(iOS)
                    iOSList
                #else
                    macOSList
                #endif
            }
        }
    }

    #if os(iOS)
        var iOSList: some View {
            list
            .listStyle(.plain)
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Chats")
            .sheet(isPresented: $isShowSettingView) {
                AppSettingsView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowSettingView = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }

                ToolbarItem(placement: .automatic) {
                    addButton
                }
            }
        }
    #endif
    
    var macOSList: some View {
        list
        .listStyle(.sidebar)
        .frame(minWidth: 280)
        .toolbar {
            Spacer()

            addButton
        }
    }
    
    var list: some View {
        List(viewModel.filteredDialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
            DialogueListItem(session: session)
        }
    }
    
    var addButton: some View {
        Button {
            viewModel.addDialogue()
        } label: {
            Image(systemName: "square.and.pencil")
        }
        .keyboardShortcut("n", modifiers: .command)
    }
}
