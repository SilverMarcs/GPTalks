//
//  ImageListRow.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/07/2024.
//

import SwiftUI

struct ImageListRow: View {
    @Bindable var session: ImageSession
    
    var body: some View {
        HStack {
            ProviderImage(provider: session.config.provider, radius: 7, frame: frame)
            
            Text(session.title)
                .font(.headline)
                .fontWeight(.regular)
                .lineLimit(1)
            
            Spacer()
            
            Text(session.config.model.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fontWidth(.compressed)
            
            if session.isStarred {
                Image(systemName: "star.fill")
                    .foregroundStyle(.orange)
                    .imageScale(.small)
            }
        }
        .padding(3)
    }
    
    var frame: CGFloat {
        #if os(macOS)
        20
        #else
        23
        #endif
    }
}

//#Preview {
//    ImageListRow()
//}
