//
//  EditButton.swift
//  GPTalks
//
//  Created by Zabir Raihan on 23/11/2024.
//

import SwiftUI

struct EditButton: View {
    var setupEditing: () -> Void

    var body: some View {
        Button(action: setupEditing) {
            Label("Edit", systemImage: "pencil.and.outline")
        }
        .help("Edit")
    }
}
