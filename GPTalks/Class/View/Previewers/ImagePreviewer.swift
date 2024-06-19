//
//  ImagePreviewer.swift
//  GPTalks
//
//  Created by Zabir Raihan on 11/06/2024.
//

import SwiftUI

struct ImagePreviewer: View {
    var imageURL: URL
    var removeImageAction: () -> Void
    var showRemoveButton: Bool = true
    var showImage: Bool = true
    
    @State var qlItem: URL?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                #if os(macOS)
                    qlItem = imageURL
                #else
                if let fileURL = absoluteURL(forRelativePath: imageURL.relativePath) {
                   qlItem = fileURL
                }
                #endif
            } label: {
                if showImage {
                    if let image = loadImage(from: properUrl) {
                        Image(platformImage: image)
                            .resizable()
                            .frame(maxWidth: 100, maxHeight: 100, alignment: .center)
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(6)
                    }
                } else {
                    HStack {
                        Group {
#if os(macOS)
                            Image(nsImage: getFileTypeIcon(fileURL: imageURL)!)
                                .resizable()
#else
                            Image(systemName: "photo")
                                .resizable()
#endif
                        }
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading) {
                            Text(imageURL.lastPathComponent)
                                .font(.callout)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            
                            if let fileSize = getFileSizeFormatted(fileURL: imageURL) {
                                HStack(spacing: 2) {
                                    Group {
                                        Text("Image •")
                                            .font(.caption)
                                        Text(fileSize)
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            } else {
                                Text("Unknown size")
                                    .font(.caption)
                            }
                        }
                        Spacer()
                    }
                    .frame(width: 215)
                    .bubbleStyle(isMyMessage: false, radius: 8)
                }
            }
            .buttonStyle(.plain)

            if showRemoveButton {
                CustomCrossButton(action: removeImageAction)
            }
        }
        .quickLookPreview($qlItem)
    }
    
    var properUrl: String {
        #if os(macOS)
        return imageURL.absoluteString
        #else
        return imageURL.relativePath
        #endif
        
    }
}
