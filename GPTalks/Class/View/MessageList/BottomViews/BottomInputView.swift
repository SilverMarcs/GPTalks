//
//  BottomInputView.swift
//  ChatGPT
//
//  Created by LuoHuanyu on 2023/3/23.
//

import SwiftUI

struct BottomInputView: View {
    
    @ObservedObject var session: DialogueSession
    @Binding var isLoading: Bool
    @State var isShowClearMessagesAlert = false

    let namespace: Namespace.ID
    
    @FocusState var isTextFieldFocused: Bool
        
    var send: (String) -> Void
        
    var body: some View {
        HStack {
            Button(action: {
                isShowClearMessagesAlert.toggle()
            }, label: {
              Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
            })
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .padding(.leading)
            
            ComposerInputView(
                session: session,
                isTextFieldFocused: _isTextFieldFocused,
                send: send
            )
        }
        .alert(
            "Warning",
            isPresented: $isShowClearMessagesAlert
        ) {
            Button(role: .destructive) {
                session.clearMessages()
            } label: {
                Text("Confirm")
            }
        } message: {
            Text("Remove all messages?")
        }
        
#if os(iOS)
        .padding([.top, .bottom], 7)
        .background(.bar)
#else
        .padding(.top, 10)
        .padding(.bottom, 13)
        .background(.bar)
//        .blendMode(.darken)
//        .saturation(40)
#endif
    }
    
    
    private var size: CGFloat {
#if os(macOS)
        19
#else
        22
#endif
    }
    
}
