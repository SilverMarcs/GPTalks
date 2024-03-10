//
//  CustomImportedImageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/03/2024.
//

import SwiftUI

struct CustomImageView: View {
    var image: PlatformImage // or NSImage for macOS
    
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

struct ImportedImages: View {
    var session: DialogueSession

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(session.inputImages.enumerated()), id: \.element) { index, inputImage in
                    ZStack(alignment: .topTrailing) {
                        CustomImageView(image: inputImage)
                            .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(6)
                        Button {
                            session.inputImages.remove(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.background)
                                .background(.primary, in: Circle())
                        }
                        .padding(7)
                    }
                }
            }
        }
    }
}
