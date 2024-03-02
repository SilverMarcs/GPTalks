//
//  GenerationView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/02/2024.
//

import SwiftUI
import SwiftUIImageViewer

struct GenerationView: View {
    var generation: ImageGeneration
    @Binding var shouldScroll: Bool
    
    var removeGeneration: () -> Void
    
    @State private var isImagePresented = false
    
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
                
                ForEach(generation.imagesData, id: \.self) { imageData in
                    HStack {
#if os(iOS)
                        if let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(width: imageSize, height: imageSize)
                                .onTapGesture {
                                    isImagePresented = true
                                }
                                .fullScreenCover(isPresented: $isImagePresented) {
                                    SwiftUIImageViewer(image: Image(uiImage: uiImage))
                                        .overlay(alignment: .topTrailing) {
                                            closeButton
                                        }
                                    
                                }
                        }
#elseif os(macOS)
                        if let nsImage = NSImage(data: imageData) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(width: imageSize, height: imageSize)
                                .onTapGesture {
                                    isImagePresented = true
                                }
                                .sheet(isPresented: $isImagePresented) {
                                    SwiftUIImageViewer(image: Image(nsImage: nsImage))
                                        .frame(width: 800, height: 800)
                                        .overlay(alignment: .topTrailing) {
                                            closeButton
                                        }
                                    
                                }
                        }
#endif
                        
                        Button {
                            saveImageData(imageData: imageData)
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.accentColor)
                                .frame(width: 14, height: 14)
                                .padding(6)
                                .padding(.top, -2)
                                .padding(.horizontal, -1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 50)
                                        .stroke(.tertiary, lineWidth: 0.5)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        #if !os(macOS)
            .contextMenu {
                Button {
                    removeGeneration()
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
        #endif
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    private var closeButton: some View {
        Button {
            isImagePresented = false
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .padding(5)
        }
        .buttonStyle(.bordered)
        .clipShape(Circle())
        .padding()
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
            300
        #endif
    }
}
