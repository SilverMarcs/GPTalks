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
        Group {
            if (session.conversations.filter { $0.role == "user" }.last)?.id == conversation.id {
                editBtn
            }
            
            if AppConfiguration.shared.alternateChatUi {
                alternateUI
            } else {
                originalUI
            }
        }
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
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 17, height: 17)
                .foregroundStyle(.secondary)
                #if !os(macOS)
                .padding(.top, 3)
                #endif

            VStack(alignment: .leading, spacing: 6) {
                Text("User")
                    .font(.title3)
                    .bold()
                
                #if os(macOS)
                Text(isExpanded || conversation.content.count <= 300 ? conversation.content : String(conversation.content.prefix(300)) + "\n\n...")
                    .textSelection(.enabled)
                #else
                Text(isExpanded || conversation.content.count <= 300 ? conversation.content : String(conversation.content.prefix(300)) + "...")
                    .textSelection(.enabled)
                #endif
                          
                #if !os(macOS)
                HStack {
                    ForEach(conversation.base64Images, id: \.self) { imageStr in
                        UploadedImage(imageStr: imageStr)
                    }
                    
                    Spacer()
                    
                    if conversation.content.count > 200 {
                        Button(action: {
                            withAnimation {
                                self.isExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        }
                        .buttonStyle(.plain)
                        .imageScale(.medium)
                    } else {
                        EmptyView()
                    }
                }
                #else

                HStack {
                    ForEach(conversation.base64Images, id: \.self) { imageStr in
                        UploadedImage(imageStr: imageStr)
                    }
                    
                    Spacer()
                    
                    Group {
                        if conversation.content.count > 300 {
                            Button(action: {
                                withAnimation {
                                    self.isExpanded.toggle()
                                }
                            }) {
                                Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                            }
                            .buttonStyle(.plain)
                            .imageScale(.medium)
                        }
                        
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
        #else
        .padding(.top, -9)
        .padding(.bottom, -14)
        #endif
        .frame(maxWidth: .infinity, alignment: .topLeading) // Align content to the top left
        .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow.opacity(0.1) : .clear)
        .animation(.default, value: conversation.content.localizedCaseInsensitiveContains(viewModel.searchText))
    }
    
    var originalUI: some View {
        VStack(alignment: .trailing, spacing: 5) {
            ForEach(conversation.base64Images, id: \.self) { imageStr in
                UploadedImage(imageStr: imageStr)
            }
            
            HStack(alignment: .lastTextBaseline) {
                #if os(macOS)
                optionsMenu
                
                #endif
                
                Text(conversation.content)
                    .bubbleStyle(isMyMessage: conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? false : true, accentColor: session.configuration.provider.accentColor)
                    .background(conversation.content.localizedCaseInsensitiveContains(viewModel.searchText) ? .yellow : .clear, in: RoundedRectangle(cornerRadius: radius))
                    .textSelection(.enabled)
            }
        }
        .padding(.leading, horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .trailing)
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
    
    
    var optionsMenu: some View {
        Menu {
            MessageContextMenu(session: session, conversation: conversation) {
                editingMessage = conversation.content
                isEditing = true
            } toggleTextSelection: {
                canSelectText.toggle()
            }
            .labelStyle(.titleAndIcon)
            
        } label: {
            Image(systemName: "ellipsis.circle")
                .buttonStyle(.plain)
        }
        .buttonStyle(.plain)
        .labelsHidden()
        .menuIndicator(.hidden)
        .opacity(isHovered ? 1 : 0)
        .transition(.opacity)
        .animation(.easeOut(duration: 0.15), value: isHovered)
    }
    
    private var horizontalPadding: CGFloat {
        #if os(iOS)
        50
        #else
        65
        #endif
    }
    
    private var radius: CGFloat {
        #if os(macOS)
        15
        #else
        18
        #endif
    }
}


struct UploadedImage: View {
    var imageStr: String
    @State var showPreview: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: "photo")
        }
        .bubbleStyle(isMyMessage: false, compact: true)
        .onTapGesture {
            showPreview = true
        }
        .popover(isPresented: $showPreview) {
#if os(macOS)
//            Image(nsImage: NSImage(data: Data(base64Encoded: imageStr)!)!)
            if let retrievedImage = retrieveImageFromDisk(url: URL(string: imageStr)!) {
                Image(nsImage: retrievedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 600, maxHeight: 600, alignment: .center)
                    .presentationCompactAdaptation((.popover))
            }
#else
            if let retrievedImage = retrieveImageFromDisk(url: URL(string: imageStr)!) {
                Image(uiImage: retrievedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 400, maxHeight: 400, alignment: .center)
                    .presentationCompactAdaptation((.popover))
            }
#endif
        }
    }
}
