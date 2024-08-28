//
//  ToggleWithDescription.swift
//  GPTalks
//
//  Created by Zabir Raihan on 27/08/2024.
//

import SwiftUI

struct ToggleWithDescription: View {
    let title: String
    @Binding var isOn: Bool
    let description: String?

    var body: some View {
        VStack(alignment: .leading) {
            Toggle(title, isOn: $isOn)
            if let description = description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
