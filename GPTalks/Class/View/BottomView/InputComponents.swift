//
//  InputComponents.swift
//  GPTalks
//
//  Created by Zabir Raihan on 28/03/2024.
//

import SwiftUI

struct SendButton: View {
    var size: CGFloat
    var send: () -> Void
    
    var body: some View {
        Button {
            send()
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .fontWeight(.semibold)
                .foregroundStyle(.white, Color.accentColor)
                .frame(width: size, height: size)
        }
        .keyboardShortcut(.return, modifiers: .command)
    }
}

struct SendButton2: View {
    var size: CGFloat
    var send: () -> Void
    
    var body: some View {
        Button {
            send()
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .fontWeight(.semibold)
                .foregroundStyle(.white, Color.accentColor)
                .frame(width: size, height: size)
        }
        .keyboardShortcut(.defaultAction)
    }
}

struct StopButton: View {
    var size: CGFloat
    var stop: () -> Void
    
    var body: some View {
        Button {
            stop()
        } label: {
            Image(systemName: "stop.circle.fill")
                .resizable()
                .fontWeight(.semibold)
                .foregroundStyle(.red)
                .frame(width: size, height: size)
        }
        .keyboardShortcut("d", modifiers: .command)
    }
}

#Preview {
//    SendButton(size: 22) {
//        
//    }
    
    StopButton(size: 22) {
        
    }
}
