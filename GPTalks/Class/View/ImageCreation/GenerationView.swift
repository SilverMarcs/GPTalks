//
//  GenerationView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/02/2024.
//

import SwiftUI

struct GenerationView: View {
    var generation: ImageGeneration
    @Binding var shouldScroll: Bool
    
    var removeGeneration: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkle")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundColor(Color("niceColorLighter"))
            #if !os(macOS)
                .padding(.top, 3)
            #endif
            
            VStack(alignment: .leading, spacing: VSpacing) {
                Text(generation.model)
                    .font(.title3)
                    .bold()
                    .textSelection(.enabled)
                
                Text(generation.prompt)
                    .textSelection(.enabled)
                
                ForEach(generation.imagesData, id: \.self) { imageData in
                    ImageView(imageData: imageData, imageSize: imageSize, showSaveButton: true)
                }
                
                if generation.isGenerating {
                    HStack {
                        ReplyingIndicatorView()
                            .frame(width: 48, height: 16)
                            .bubbleStyle(isMyMessage: false)
                        
                        Button {
                            generation.stopGenerating()
                        } label: {
                            Image(systemName: "stop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if !generation.errorDesc.isEmpty {
                    Text(generation.errorDesc)
                        .foregroundColor(.red)
                }
                
                Color.clear
                    .frame(height: 10)
            }
        }
        .contextMenu {
            Button {
                withAnimation {
                    removeGeneration()
                }
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    private var VSpacing: CGFloat {
        #if os(macOS)
            return 6
        #else
            return 10
        #endif
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
            275
        #endif
    }
}


