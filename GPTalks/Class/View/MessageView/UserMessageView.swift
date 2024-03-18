//
//  UserMessageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/12/2023.
//

import SwiftUI

struct UserMessageView: View {
    @Environment(DialogueViewModel.self) private var viewModel
    
    @State private var isExpanded = false
    
    var conversation: Conversation
    var session: DialogueSession

    @State var isEditing: Bool = false
    @State var editingMessage: String = ""
    
    @State private var isHovered = false
    
    @State var canSelectText = false
    
    @State var showPreview: Bool = false

    var body: some View {
        alternateUI
        #if os(macOS)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                if (session.conversations.filter { $0.role == "user" }.last)?.id == conversation.id {
                    editBtn
                }
            }
        }
        #endif
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        .sheet(isPresented: $isEditing) {
            EditingView(editingMessage: $editingMessage, isEditing: $isEditing, session: session, conversation: conversation)
        }
        #if os(iOS)
        .sheet(isPresented: $canSelectText) {
            TextSelectionView(content: conversation.content)
        }
        .contextMenu {
            MessageContextMenu(session: session, conversation: conversation) {
                editingMessage = conversation.content
                isEditing = true
            } toggleTextSelection: {
                canSelectText.toggle()
            }
            .labelStyle(.titleAndIcon)
        }
        #endif
    }
    
    var alternateUI: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
//                .foregroundStyle(.secondary)
                .foregroundColor(Color("blueColorLighter"))
                #if !os(macOS)
                .padding(.top, 3)
                #endif

            VStack(alignment: .leading, spacing: 6) {
                Text("User")
                    .font(.title3)
                    .bold()
                
                #if os(macOS)
                Text(isExpanded || conversation.content.count <= 300 ? conversation.content : String(conversation.content.prefix(300)) + "\n...")
                    .textSelection(.enabled)
                #else
                Text(isExpanded || conversation.content.count <= 300 ? conversation.content : String(conversation.content.prefix(300)) + "...")
                    .textSelection(.enabled)
                #endif
                          
                #if !os(macOS)
                HStack {
                    ForEach(conversation.imagePaths, id: \.self) { imagePath in
                        if let imageData = getImageData(fromPath: imagePath) {
                            ImageView(imageData: imageData, imageSize: imageSize, showSaveButton: false)
                        }
                    }
                    
                    Spacer()
                    
                    expandToggle(limit: 200)
                }
                #else
                ForEach(conversation.imagePaths, id: \.self) { imagePath in
                    if let imageData = getImageData(fromPath: imagePath) {
                        ImageView(imageData: imageData, imageSize: imageSize, showSaveButton: false)
                    }
                }

                HStack {
                    Spacer()
                    
                    Group {
                        expandToggle(limit: 300)
                        
                        MessageContextMenu(session: session, conversation: conversation) {
                            editingMessage = conversation.content
                            isEditing = true
                        } toggleTextSelection: {
                            canSelectText.toggle()
                        }
                        .labelStyle(.iconOnly)
                    }
                    .opacity(isHovered ? 1 : 0)
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.15), value: isHovered)
                }
                #endif
            }

            Spacer()
        }
        .padding()
        #if os(macOS)
        .padding(.horizontal, 8)
        .padding(.bottom, -6) // need at least -2 padding here
//        #else
//        .padding(.top, -9)
//        .padding(.bottom, -14)
        #endif
        .frame(maxWidth: .infinity, alignment: .topLeading) // Align content to the top left
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.1) : .clear)
        .animation(.default, value: conversation.content.localizedCaseInsensitiveContains(viewModel.searchText))
    }
    
  
    @ViewBuilder
    func expandToggle(limit: Int) -> some View {
        if conversation.content.count > limit {
            Button {
//                withAnimation {
                    self.isExpanded.toggle()
//                }
            } label: {
                Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
            }
            .buttonStyle(.plain)
            .imageScale(.medium)
        } else {
            EmptyView()
        }
    }
    
    var editBtn: some View {
        Button("") {
            editingMessage = conversation.content
            isEditing = true
        }
        .frame(width: 0, height: 0)
        .hidden()
        .keyboardShortcut("e", modifiers: .command)
        .padding(4)
    }

    private var imageSize: CGFloat {
        #if os(macOS)
        300
        #else
        325
        #endif
    }
}
