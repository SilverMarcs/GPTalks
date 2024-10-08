//
//  ActionButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/14/24.
//

import SwiftUI

struct ActionButton: View {
    var size: CGFloat = 24
    var isStop: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isStop ? "stop.circle.fill" : "arrow.up.circle.fill")
                .resizable()
                .frame(width: size, height: size)
                .fontWeight(.semibold)
        }
        .foregroundStyle((isStop ? AnyShapeStyle(.background) : AnyShapeStyle(.white)), (isStop ? .red : .accent))
        .buttonStyle(.plain)
        .contentTransition(.symbolEffect(.replace, options: .speed(2)))
//        .keyboardShortcut(isStop ? "d" : .return)
    }
}
