//
//  GenerationView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/02/2024.
//

import NetworkImage
import SwiftUI

struct GenerationView: View {
    var generation: ImageObject
    @Binding var shouldScroll: Bool
    
    var body: some View {
        VStack(spacing: spacing) {
            VStack(alignment: .trailing, spacing: 5) {
                Text(generation.imageModel)
                    .font(.caption)
                    .bubbleStyle(isMyMessage: false, compact: true)
                Text(generation.prompt)
                    .textSelection(.enabled)
                    .bubbleStyle(isMyMessage: true)
            }
            .padding(.leading, horizontalPadding)
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            if generation.isGenerating {
                ReplyingIndicatorView()
                    .frame(width: 48, height: 16)
                    .bubbleStyle(isMyMessage: false)
//                    .padding(.trailing, horizontalPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ForEach(generation.urls, id: \.self) { url in
                HStack(spacing: spacing) {
                    NetworkImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: imageSize, height: imageSize)
#if !os(macOS)
                            .contextMenu {
                                Button(action: {
                                    saveImage(url: url)
                                }) {
                                    Text("Save Image")
                                    Image(systemName: "square.and.arrow.down")
                                }
                            }
#endif
                    } placeholder: {
                        ZStack(alignment: .center) {
                            Color.secondary
                                .opacity(0.1)
                                .frame(width: imageSize, height: imageSize)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            ProgressView()
                        }
                        .onAppear {
                            shouldScroll = true
                        }
                        .onDisappear {
                            shouldScroll = false
                        }
                    }

                    #if os(macOS)
                    Button {
                        saveImage(url: url)
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .resizable()
                            .scaledToFit()
                            .padding(.leading, 8)
                            .padding(.trailing, 7)
                            .padding(.bottom, 8)
                            .padding(.top, 6)
                            .background(.gray.opacity(0.2))
                            .foregroundStyle(.secondary)
                            .clipShape(Circle())
                            .frame(width: btnSize, height: btnSize)
                    }
                    .buttonStyle(.plain)
                    #endif
                    
                    Spacer()
                }
                .padding(.trailing, horizontalPadding - 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var btnSize: CGFloat {
        #if os(macOS)
            return 28
        #else
            return 34
        #endif
    }
    
    private var horizontalPadding: CGFloat {
        #if os(macOS)
            85
        #else
            40
        #endif
    }
    
    private var spacing: CGFloat {
        #if os(macOS)
            return 10
        #else
            return 10
        #endif
    }
    
    private var imageSize: CGFloat {
        #if os(macOS)
            400
        #else
            325
        #endif
    }
}

//                    .onTapGesture {
//                        previewUrl = image.url!
//                        isFocused = false
//                        isZoomViewPresented = true
//                    }
//                    .contextMenu {
//                        Button(action: {
//                            saveImage(url: URL(string: image.url!))
//                        }) {
//                            Text("Save Image")
//                            Image(systemName: "square.and.arrow.down")
//                        }
//                    }
