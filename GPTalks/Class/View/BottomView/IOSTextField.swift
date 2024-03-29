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
    
    @Binding var input: String
    var isReplying: Bool
    @FocusState var focused: Bool
    
    var send: () -> Void
    var stop: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TextField("Send a message", text: $input, axis: .vertical)
//                .keyboardType(.asciiCapable)
//                .autocorrectionDisabled(true)
//                .textContentType(.init(rawValue: ""))
                .focused($focused)
                .multilineTextAlignment(.leading)
                .lineLimit(1 ... 15)
                .padding(6)
                .padding(.horizontal, 5)
                .padding(.trailing, 25) // for avoiding send button
                .frame(minHeight: imageSize + 5)
                .background(
//                    VisualEffect(colorTint: colorScheme == .dark ? .black : .white, colorTintAlpha: 0.3, blurRadius: 18, scale: 1)
                    VisualEffect(colorTint: colorScheme == .dark 
                                 ?
                                 (focused ? Color(hex: "666668")
                                 :
                                 (.black))
                                 : .white, colorTintAlpha: 0.3, blurRadius: 18, scale: 1)
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
                    Group {
                        if isReplying {
                            StopButton(size: imageSize - 3) {
                                stop()
                            }
                        } else {
                            SendButton(size: imageSize - 3) {
                                send()
                            }
                        }
                    }
                    .offset(x: -4, y: -4)
                }
            }
            .padding(20) // Increase tappable area
            .padding(-20) // Cancel out visual expansion
            .background(Color.clear)
        }
        .onTapGesture {
            focused = true
        }
        .roundedRectangleOverlay(opacity: focused ? 0 : (colorScheme == .dark ? 0.8 : 0.5))
    }

    @ViewBuilder
    private var sendButton: some View {
        Button {
            send()
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .keyboardShortcut(.return, modifiers: .command)
                .fontWeight(.semibold)
                .foregroundStyle(.foreground, Color.accentColor)
                .frame(width: imageSize - 3, height: imageSize - 3)
        }
        .keyboardShortcut(.return, modifiers: .command)
    }

    @ViewBuilder
    private var stopButton: some View {
        Button {
            stop()
        } label: {
            Image(systemName: "stop.circle.fill")
                .resizable()
                .keyboardShortcut("d", modifiers: .command)
                .foregroundStyle(.foreground, .red)
                .frame(width: imageSize - 3, height: imageSize - 3)
        }
        .keyboardShortcut("d", modifiers: .command)
    }

    private var imageSize: CGFloat {
        31
    }
}
#endif
