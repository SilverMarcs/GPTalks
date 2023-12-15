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
                .listStyle(.plain)
            #else
                macOSList
                .listStyle(.sidebar)
            #endif
        }
    }

    #if os(iOS)
        var iOSList: some View {
            list
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
    
    var list: some View {
        List(viewModel.filteredDialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
            NavigationLink(destination: MessageListView(session: session)) {
                DialogueListItem(session: session)
            }
        }
        #if os(iOS)
        .searchable(text: $viewModel.searchText)
        #endif
    }
    
    var addButton: some View {
        Button {
            viewModel.addDialogue()
        } label: {
            Image(systemName: "square.and.pencil")
        }
    }
}
