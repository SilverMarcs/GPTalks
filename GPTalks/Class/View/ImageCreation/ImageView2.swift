//
//  ImageView2.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/04/2024.
//

import SwiftUI
import QuickLook

struct ImageView2: View {
    let imageUrlPath: String
    let imageSize: CGFloat
    var showSaveButton: Bool = false
    
    @State var qlItem: URL?
    
    var body: some View {
        HStack {
            if let image = loadImage(from: imageUrlPath) {
                Image(platformImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(maxWidth: imageSize, maxHeight: imageSize, alignment: .center)
                    .onTapGesture {
                        setupQLItem()
                    }
                    .quickLookPreview($qlItem)
            }
            
            if showSaveButton {
                saveButton
            } else {
                EmptyView()
            }
        }
    }
    
    private func setupQLItem() {
        #if os(macOS)
        qlItem = URL(string: imageUrlPath)!
        #else
        if let fileURL = absoluteURL(forRelativePath: imageUrlPath) {
           qlItem = fileURL
        }
        #endif
    }
    
    private var saveButton: some View {
        Button {
            if let imageData = loadImageData(from: imageUrlPath) {
             saveImageData(imageData: imageData)
            }
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
