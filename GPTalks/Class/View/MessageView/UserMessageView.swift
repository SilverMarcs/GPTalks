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
    @State var hoverxyz = false
    
    @State var canSelectText = false
    
    @State var showPreview: Bool = false

    var body: some View {
        alternateUI
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        .sheet(isPresented: $isEditing) {
            EditingView(editingMessage: $editingMessage, isEditing: $isEditing, session: session, conversation: conversation)
        }
        #if !os(macOS)
        .sheet(isPresented: $canSelectText) {
            TextSelectionView(content: conversation.content)
        }
        .contextMenu {
            MessageContextMenu(session: session, conversation: conversation, isExpanded: isExpanded,
            editHandler: {
                session.setupEditing(conversation: conversation)
            }, toggleTextSelection: {
                canSelectText.toggle()
            }, toggleExpanded: {
                isExpanded.toggle()
            })
            .labelStyle(.titleAndIcon)
        }
        #else
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                if (session.conversations.filter { $0.role == .user }.last)?.id == conversation.id {
                    editBtn
                }
            }
        }
        #endif
    }
    
    @State var dynamicHeight: CGFloat = 1
    
    var alternateUI: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color("blueColorLighter"))
#if !os(macOS)
                    .padding(.top, 3)
#else
                    .offset(y: 1)
#endif
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("User")
                        .font(.title3)
                        .bold()
                    
#if os(macOS)
                    Text(isExpanded || conversation.content.count <= 300 ? conversation.content : String(conversation.content.prefix(300)) + "\n...")
                        .textSelection(.enabled)
#else
                    
                    TextViewWrapper(text: Binding.constant(conversation.content), dynamicHeight: $dynamicHeight)
                        .frame(height: dynamicHeight)
#endif
                    
                    ForEach(conversation.imagePaths, id: \.self) { imagePath in
                        ImageView2(imageUrlPath: imagePath, imageSize: imageSize)
                    }
                    
                    if let audioUrl = URL(string: conversation.audioPath) {
                        AudioPreviewer(audioURL: audioUrl,showRemoveButton: false, removeAudioAction: {})
//                            .frame(maxWidth: 500)
                    }
                    
                    if let pdfURL = URL(string: conversation.pdfPath) {
                        PDFViewer(pdfURL: pdfURL, removePDFAction: {}, showRemoveButton: false)
                    }
                }
                
                Spacer()
            }
            .padding()
#if os(macOS)
            HStack {
                Spacer()
                
                messageContextMenu
                    .padding(.leading, 200) // Increase padding to enlarge the invisible hover area
  //                  .background(Color.blue.opacity(0.1)) // Optional: Just to visualize the area during development
                    .contentShape(Rectangle()) // Make the whole padded area hoverable
                    .onHover { isHovered in
                        hoverxyz = isHovered
                    }
                    .animation(.easeInOut(duration: 0.15), value: hoverxyz)
            }
//            .padding(10)
            .padding(.top, -40)
            .padding(.bottom, 3)
            .padding(.horizontal, 18)
#endif
        }

        #if os(macOS)
        .padding(.horizontal, 8)
        #endif
        .frame(maxWidth: .infinity, alignment: .topLeading) // Align content to the top left
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.1) : .clear)
        .background(session.conversations.firstIndex(where: { $0.id == conversation.id }) == session.editingIndex ? Color("niceColor").opacity(0.3) : .clear)
        .animation(.default, value: conversation.content.localizedCaseInsensitiveContains(viewModel.searchText))
    }
    
    var messageContextMenu: some View {
        HStack {
            if hoverxyz {
                MessageContextMenu(session: session, conversation: conversation, isExpanded: isExpanded,
                editHandler: {
                    session.setupEditing(conversation: conversation)
                }, toggleTextSelection: {
                    canSelectText.toggle()
                }, toggleExpanded: {
                    withAnimation {
                        isExpanded.toggle()
                    }
//                    isExpanded.toggle()
                })
            } else {
                Image(systemName: "ellipsis")
                    .frame(width: 17, height: 17)
            }

        }
        .contextMenuModifier(isHovered: $isHovered)
    }
    
    var editBtn: some View {
        Button("") {
            session.setupEditing(conversation: conversation)
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
