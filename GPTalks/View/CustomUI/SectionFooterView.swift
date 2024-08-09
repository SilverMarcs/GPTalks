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
        HStack {
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        #if os(macOS)
        .padding(.leading, 5)
        #endif
    }
}

#Preview {
    SectionFooterView(text: "hi")
}