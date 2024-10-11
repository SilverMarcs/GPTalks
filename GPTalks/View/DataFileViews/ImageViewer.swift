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
                    .frame(width: CGFloat(imageConfig.chatImageWidth), height: CGFloat(imageConfig.chatImageHeight))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                Text("Image Unable to Load")
                    .frame(width: 100, height: 48)
            }
        }
        .buttonStyle(.plain)
    }
}
