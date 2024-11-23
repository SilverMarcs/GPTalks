//
//  ResetContextButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct ResetContextButton: View {
    var message: MessageGroup
    
    var body: some View {
        Button {
            message.chat?.resetContext(at: message)
        } label: {
            Label("Reset Context", systemImage: "eraser")
        }
        .help("Reset Context")
    }
}
