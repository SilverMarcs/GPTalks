//
//  ImageViewerData.swift
//  GPTalks
//
//  Created by Zabir Raihan on 29/09/2024.
//

import SwiftUI

struct ImageViewerData: View {
    @ObservedObject var imageConfig = ImageConfigDefaults.shared
    let data: Data
    
    @State private var selectedFileURL: URL?
    
    var body: some View {
        Button(action: onTap) {
            if let image = PlatformImage.from(data: data) {
                Image(platformImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: CGFloat(imageConfig.imageWidth), height: CGFloat(imageConfig.imageHeight))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

            } else {
                Text("Image Unable to Load")
                    .frame(width: CGFloat(imageConfig.imageWidth), height: CGFloat(imageConfig.imageHeight))
            }
        }
        .quickLookPreview($selectedFileURL)
        .buttonStyle(.plain)
    }
    
    func onTap() {
        if let url = FileHelper.createTemporaryURL(for: data) {
            selectedFileURL = url
        }
    }
}
