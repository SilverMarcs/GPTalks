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
            List(viewModel.dialogues) { session in
                NavigationLink {
                    MessageListView(session: session)
                } label: {
                    DialogueListItem(session: session)
                }
            }
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.large)
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
                    Button {
                        viewModel.addDialogue()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
    #endif

    var macOSList: some View {
        List(viewModel.dialogues) { session in
            NavigationLink {
                MessageListView(session: session)
            } label: {
                DialogueListItem(session: session)
            }
        }
        .frame(minWidth: 290)
        .toolbar {
            ToolbarItem {
                Spacer()
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    viewModel.addDialogue()
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }
}
