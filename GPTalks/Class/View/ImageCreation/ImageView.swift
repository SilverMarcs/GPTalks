//
//  ImageView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 03/03/2024.
//

import SwiftUI
import SwiftUIImageViewer

struct ImageView: View {
    let imageData: Data
    let imageSize: CGFloat
    var showSaveButton: Bool = false
    
    @State var isImagePresented = false
    
    var body: some View {
        HStack {
#if os(macOS)
            macOS
#else
            iOS
#endif
            if showSaveButton {
                saveButton
            } else {
                EmptyView()
            }
        }
    }
    
    #if os(macOS)
    @ViewBuilder
    var macOS: some View {
        if let nsImage = NSImage(data: imageData) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(maxWidth: imageSize, maxHeight: imageSize, alignment: .center)
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
    }
    #else
    @ViewBuilder
    var iOS: some View {
        if let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(maxWidth: imageSize, maxHeight: imageSize, alignment: .center)
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
    }
    #endif
    
    private var closeButton: some View {
        Button {
            isImagePresented = false
        } label: {
            Image(systemName: "xmark.circle.fill")
                .resizable()
            #if os(macOS)
                .frame(width: 20, height: 20)
            #else
                .frame(width: 30, height: 30)
            #endif
                .foregroundStyle(.foreground.secondary, Color.gray.opacity(0.2))
//                .font(.headline)
//                .padding(5)
        }
        .buttonStyle(.plain)
//        .clipShape(Circle())
        .padding()
    }
    
    private var saveButton: some View {
        Button {
            saveImageData(imageData: imageData)
        } label: {
            Image(systemName: "square.and.arrow.down")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.primary)
                .fontWeight(.bold)
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
