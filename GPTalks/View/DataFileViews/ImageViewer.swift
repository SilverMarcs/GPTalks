//
//  ImageViewer.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/20/24.
//

import SwiftUI

struct ImageViewer: View {
    let typedData: TypedData
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            if let image = PlatformImage.from(data: typedData.data) {
                Image(platformImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                FileViewer(typedData: typedData, onTap: onTap)
            }
        }
        .buttonStyle(.plain)
    }
}
