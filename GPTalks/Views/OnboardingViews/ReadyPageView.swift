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
                .foregroundColor(.green)
            
            Text("Ready to Go")
                .font(.title)
                .bold()
            
            Text("You're all set to begin your journey!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
        }
    }
}

#Preview {
    ReadyPageView()
        .frame(width: 500, height: 500)
}
