//
//  SectionFooterView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/9/24.
//

import SwiftUI

struct SectionFooterView: View {
    var text: String
    
    var body: some View {
        #if os(macOS) || targetEnvironment(macCatalyst)
        HStack {
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.leading, 5)
        #else
        Text(text)
        #endif
    }
}

#Preview {
    SectionFooterView(text: "hi")
}
