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
                .focused($focused)
                .multilineTextAlignment(.leading)
                .lineLimit(1 ... 15)
                .padding(6)
                .padding(.horizontal, 5)
                .padding(.trailing, 25) // for avoiding send button
                .frame(minHeight: imageSize + 7)
                .background(
//                    VisualEffect(colorTint: colorScheme == .dark 
//                                 ? Color(hex: "48484A")
//                                 : Color(hex: "CACACE"),
//                                 colorTintAlpha: 0.3, blurRadius: 18, scale: 1)
//                        .cornerRadius(18)
                    
//                    .clear
                    
                    VisualEffect(colorTint: colorScheme == .dark
                                 ? Color(hex: "101010")
                                 : Color(hex: "FAFAFE"),
                                 colorTintAlpha: 0.3, blurRadius: 18, scale: 1)
                        .cornerRadius(18)
                )
                .roundedRectangleOverlay()
            
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
                    .offset(x: -10, y: -10)
                } else {
                    Group {
                        if isReplying {
                            StopButton(size: imageSize - 1) {
                                stop()
                            }
                        } else {
                            SendButton(size: imageSize - 1) {
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
    }

    private var imageSize: CGFloat {
        31
    }
}
#endif
