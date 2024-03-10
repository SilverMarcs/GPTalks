//
//  IOSTextField.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024.
//

#if !os(macOS)
import SwiftUI
import VisualEffectView

struct IOSTextField: View {
    @Environment(\.colorScheme) var colorScheme
    
    @FocusState var focused: Bool
    @Binding var input: String
    var isReplying: Bool
    
    var send: () -> Void
    var stop: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TextField("Send a message", text: $input, axis: .vertical)
                .focused($focused)
                .multilineTextAlignment(.leading)
                .lineLimit(1 ... 15)
                .padding(6)
                .padding(.horizontal, 5)
                .padding(.trailing, 25) // for avoiding send button
                .frame(minHeight: imageSize + 5)
                .background(
                    VisualEffect(colorTint: colorScheme == .dark ? .black : .white, colorTintAlpha: 0.3, blurRadius: 18, scale: 1)
                        .cornerRadius(18)
                )
            
            Group {
                if input.isEmpty && !isReplying {
                    Button {} label: {
                        Image(systemName: "mic.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize - 13, height: imageSize - 13)
                            .foregroundStyle(.secondary)
                            .opacity(0.5)
                    }
                    .offset(x: -10, y: -9)
                } else {
                    if isReplying {
                        stopButton
                            .offset(x: -4, y: -4)
                        
                    } else {
                        sendButton
                            .offset(x: -4, y: -4)
                    }
                }
            }
            .padding(20) // Increase tappable area
            .padding(-20) // Cancel out visual expansion
            .background(Color.clear)
        }
        .onTapGesture {
            focused = true
        }
        .roundedRectangleOverlay()
    }

    @ViewBuilder
    private var sendButton: some View {
        let empty = input.isEmpty
        
        Button {
            send()
        } label: {
            Image(systemName: empty ? "arrow.up.circle" : "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(empty ? .secondary : .accentColor)
                .background(.white)
                .clipShape(Circle())
                .frame(width: imageSize - 3, height: imageSize - 3)
        }
        .keyboardShortcut(.return, modifiers: .command)
        .fontWeight(.semibold)
        .animation(.interactiveSpring, value: empty)
    }

    @ViewBuilder
    private var stopButton: some View {
        Button {
            stop()
        } label: {
            Image(systemName: "stop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize - 3, height: imageSize - 3)
                .foregroundColor(.red)
        }
        .keyboardShortcut("d", modifiers: .command)
    }

    private var imageSize: CGFloat {
        31
    }
}
#endif
