//
//  ReadyPageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI

struct ReadyPageView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text("Ready to Go")
                .font(.title)
                .bold()
            
            Text(text)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    #if os(macOS)
    let text = "You can configure much more in Settings (⌘ + ,)"
    #else
    let text = "You can configure much more in Settings"
    #endif
}

#Preview {
    ReadyPageView()
        .frame(width: 500, height: 500)
}
