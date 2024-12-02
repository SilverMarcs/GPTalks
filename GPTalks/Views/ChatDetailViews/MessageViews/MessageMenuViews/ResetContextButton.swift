//
//  ResetContextButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct ResetContextButton: View {
    var resetContext: () -> Void

    var body: some View {
        Button(action: resetContext) {
            Label("Reset Context", systemImage: "eraser")
        }
        .help("Reset Context")
    }
}
