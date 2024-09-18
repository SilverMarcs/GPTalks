//
//  ImageViewer.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/20/24.
//

import SwiftUI

struct ImageViewer: View {
    @ObservedObject var imageConfig = ImageConfigDefaults.shared
    
    let typedData: TypedData
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            if let image = PlatformImage.from(data: typedData.data) {
                Image(platformImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: CGFloat(imageConfig.imageWidth), height: CGFloat(imageConfig.imageHeight))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                FileViewer(typedData: typedData, onTap: onTap)
            }
        }
        .buttonStyle(.plain)
    }
}
