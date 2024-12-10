//
//  DeleteButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct DeleteButton: View {
    var deleteLastMessage: () -> Void

    var body: some View {
        Button(role: .destructive, action: deleteLastMessage) {
            Label("Delete Message", systemImage: "minus.circle")
        }
    }
}
