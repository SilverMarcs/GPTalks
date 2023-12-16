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
        Group {
            #if os(iOS)
                iOSList
            #else
                macOSList
            #endif
        }
    }

    #if os(iOS)
        var iOSList: some View {
            List(selection: $viewModel.selectedDialogue) {
                ForEach(viewModel.filteredDialogues, id: \.self) { session in
                    NavigationLink(destination: MessageListView(session: session)) {
                        DialogueListItem(session: session)
                    }
                }
            }
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
        List(viewModel.filteredDialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
            NavigationLink(destination: MessageListView(session: session)) {
                DialogueListItem(session: session)
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 280)
        .toolbar {
            ToolbarItem {
                Spacer()
            }
            ToolbarItem(placement: .automatic) {
                addButton
            }
        }
    }
    
    var addButton: some View {
        Button {
            viewModel.addDialogue()
        } label: {
            Image(systemName: "square.and.pencil")
        }
    }
}
