//
//  InputViewButtons.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024.
//

import SwiftUI

struct MacSendButton:  View {
    var isInputEmpty: Bool
    var isReplying: Bool

    var send: () -> Void
    
    var body: some View {
        Button {
            send()
        } label: {
            Image(systemName: isInputEmpty ? "arrow.up.circle" : "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(isInputEmpty ? .secondary : .accentColor)
                .frame(width: 22, height: 22)
        }
        .keyboardShortcut(.return, modifiers: .command)
        .disabled(isInputEmpty || isReplying)
        .fontWeight(.semibold)
        .animation(.interactiveSpring, value: isInputEmpty)
    }
}

//@ViewBuilder
struct StopButton: View {
    var stop: () -> Void
    
    var body: some View {
        Button {
            stop()
        } label: {
            Image(systemName: "stop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
                .foregroundColor(.red)
        }
        .keyboardShortcut("d", modifiers: .command)
    }
    
    private var imageSize: CGFloat {
        #if os(macOS)
        21
        #else
        28
        #endif
    }
}
//
//@ViewBuilder
//private var inputBox: some View {
//    ZStack(alignment: .leading) {
//        #if os(macOS)
//        textEditor
//        #else
//        textField
//        #endif
//    }
//    .roundedRectangleOverlay()
//}
//
//#Preview {
//    InputViewButtons()
//}
