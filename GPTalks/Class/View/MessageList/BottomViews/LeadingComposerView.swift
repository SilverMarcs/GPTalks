//
//  LeadingComposerView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/17.
//

import SwiftUI
import PhotosUI

struct LeadingComposerView: View {
    
    @ObservedObject var session: DialogueSession
    
    @State var selectedPromt: Prompt?
    
    @State var showPromptPopover: Bool = false
    
    private var height: CGFloat {
#if os(iOS)
        22
#else
        17
#endif
    }
    
    var body: some View {
//            if session.inputData == nil && !session.isSending {
                Menu {
                    ForEach(PromptManager.shared.prompts) { promt in
                        Button {
                            session.input = promt.prompt
                        } label: {
                            Text(promt.act)
                        }
                    }
                } label: {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: height)
                        .foregroundColor(.gray)
                        .ignoresSafeArea(.keyboard)
                }
                .menuIndicator(.hidden)
                .ignoresSafeArea(.keyboard)
#if os(macOS)
                .buttonStyle(.borderless)
//                .padding(-4)
#endif
//            }
    }
}
