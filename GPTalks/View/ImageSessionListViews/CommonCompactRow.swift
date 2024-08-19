//
//  CommonCompactRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 20/07/2024.
//

import SwiftUI

struct CommonCompactRow: View {
    var provider: Provider
    var model: AIModel
    var title: String
    var isStarred: Bool
    
    var body: some View {
        HStack {
            ProviderImage(provider: provider, radius: 8, frame: 23, scale: .medium)
            
            Text(title)
                .lineLimit(1)
                .font(.headline)
                .fontWeight(.regular)
                .opacity(0.9)
            
            Spacer()
            
            Text(model.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fontWidth(.compressed)
            
            if isStarred {
                Image(systemName: "star.fill")
                    .foregroundStyle(.orange)
                    .imageScale(.small)
                    .symbolEffect(.appear, isActive: !isStarred)
            }
        }
        .padding(3)
    }
}

//#Preview {
//    CommonCompactRow()
//}
