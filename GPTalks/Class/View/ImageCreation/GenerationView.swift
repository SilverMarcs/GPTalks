//
//  GenerationView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/02/2024.
//

import SwiftUI
import NetworkImage

struct GenerationView: View {
    var generation: ImageObject
    
    var body: some View {
        VStack(spacing: spacing) {
            HStack(alignment: .lastTextBaseline) {
                Text(generation.prompt)
                    .textSelection(.enabled)
                    .bubbleStyle(isMyMessage: true)
            }
            .padding(.leading, horizontalPadding)
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            if (generation.isGenerating) {
                Text("Generating...")
            }
            
            ForEach(generation.urls, id: \.self.url) { image in
                NetworkImage(url: URL(string: image.url!)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    //            AsyncImage(url: URL(string: image.url!)) { asyncImage in
                    //                asyncImage
                    //                    .resizable()
                    //                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    //                    .scaledToFit()
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
                } placeholder: {
                    ProgressView()
                }
                .padding(.trailing, horizontalPadding)
#if os(iOS)
                .sheet(isPresented: $isZoomViewPresented) {
                    ZoomableImageView(imageUrl: URL(string: previewUrl))
                }
#endif
                .listRowSeparator(.hidden)
                //                .onAppear {
                //                    feedback = ""
                //                }
            }
        }
    }
    
    
    private var horizontalPadding: CGFloat {
        #if os(iOS)
            50
        #else
            85
        #endif
    }
    
    private var spacing: CGFloat {
        #if os(macOS)
            return 10
        #else
            return 2
        #endif
    }
}
