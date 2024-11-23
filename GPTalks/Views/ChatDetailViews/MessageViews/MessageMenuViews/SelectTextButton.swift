//
//  SelectTextButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct SelectTextButton: View {
    var toggleTextSelection: (() -> Void)?
    
    var body: some View {
        Button {
            toggleTextSelection?()
        } label: {
            Label("Select Text", systemImage: "text.cursor")
        }
        .help("Select Text")
    }
}
