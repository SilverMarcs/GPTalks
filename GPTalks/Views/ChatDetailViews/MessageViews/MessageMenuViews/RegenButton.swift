//
//  RegenButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct RegenButton: View {
    var regenerate: () -> Void

    var body: some View {
        Button(action: regenerate) {
            Label("Regenerate", systemImage: "arrow.2.circlepath")
        }
    }
}
