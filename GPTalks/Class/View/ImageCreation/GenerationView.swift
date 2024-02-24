//
//  GenerationView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/02/2024.
//

//import NetworkImage
import SwiftUI

struct GenerationView: View {
    var generation: ImageGeneration
    @Binding var shouldScroll: Bool
    
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
                
                Text(generation.prompt)
                    .textSelection(.enabled)
                
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
                
                // TODO: make grid
                ForEach(generation.urls, id: \.self) { url in 
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: imageSize, height: imageSize)
                        #if !os(macOS)
                            .contextMenu {
                                Button {
                                    saveImage(url: url)
                                } label: {
                                    Label("Save Image", systemImage: "square.and.arrow.down")
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
                    }
                }
                
                Color.clear
                #if os(macOS)
                    .frame(height: 10)
                #else
                    .frame(height: 30)
                #endif
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
            325
        #endif
    }
}
