//
//  MacOSDialogList.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import OpenAI
import SwiftUI

struct MacOSDialogList: View {
    @Bindable var viewModel: DialogueViewModel

    var body: some View {
        Group {
            if viewModel.shouldShowPlaceholder {
                PlaceHolderView(imageName: "message.fill", title: viewModel.placeHolderText)
            } else {
                ScrollViewReader { proxy in
                    List(viewModel.currentDialogues, id: \.self, selection: $viewModel.selectedDialogue) { session in
                        DialogueListItem(session: session)
                            .id(session.id)
                            .listRowSeparator(.hidden)
                            .accentColor(.accentColor) // to keep row colors untouched
                    }
                    .accentColor(Color("niceColorLighter")) // to change list seldction color
                    .searchable(text: $viewModel.searchText, placement: .toolbar)
                    .animation(.default, value: viewModel.selectedState)
                    .animation(.default, value: viewModel.searchText)
                    .padding(.top, -10)
                    .onChange(of: viewModel.activeDialogues.count) {
//                         this is faaar from perfect but is required if we ant to keep list style inset which is required for animations
                        if !viewModel.activeDialogues.isEmpty {
                            proxy.scrollTo(viewModel.activeDialogues[0].id, anchor: .top)
                        }
                    }
                }
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .frame(minWidth: 280)
        .toolbar {
//            Spacer()

            Picker("Select State", selection: $viewModel.selectedState) {
                ForEach(ContentState.allCases) { state in
                    Text(state.rawValue).tag(state)
                }
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


//struct SearchBarView: View {
//    @Binding var text: String
//    var placeholder: String = "Search"
//    
//    var body: some View {
//        HStack {
//            Image(systemName: "magnifyingglass")
//            
//            TextField(placeholder, text: $text)
//                .textFieldStyle(.plain)
//                
//            if !text.isEmpty {
//                Button {
//                    self.text = ""
//                } label:  {
//                    Image(systemName: "xmark.circle.fill")
////                        .foregroundColor(.gray)
//                }
//                .buttonStyle(.plain)
//            }
//        }
//        .padding(6)
////        .background(RoundedRectangle(cornerRadius: 6).fill(Color(.gray).opacity(0.2)))
//        .background(RoundedRectangle(cornerRadius: 6).fill(.ultraThinMaterial))
//        .overlay(
//            RoundedRectangle(cornerRadius: 7)
//                .stroke(Color.gray, lineWidth: 0.4) // Adjust the lineWidth to make the border thinner or thicker
//        )
//    }
//}
