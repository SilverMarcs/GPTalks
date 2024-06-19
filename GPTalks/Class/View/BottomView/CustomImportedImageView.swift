//
//  CustomImportedImageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024.
//

import SwiftUI

struct CustomImageView: View {
    var image: PlatformImage
    
    var body: some View {
        Group {
#if os(macOS)
            Image(nsImage: image)
                .resizable()
#else
            Image(uiImage: image)
                .resizable()
#endif
        }
        .scaledToFill()
        .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
        .aspectRatio(contentMode: .fill)
        .cornerRadius(6)
    }
}


struct CustomCrossButton: View {
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.background)
                .background(.primary, in: Circle())
        }
        .padding(7)
        .buttonStyle(.plain)
    }
}
