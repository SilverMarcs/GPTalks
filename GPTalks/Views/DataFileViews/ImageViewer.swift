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
    
    var body: some View {
        if let image = PlatformImage.from(data: typedData.data) {
            Image(platformImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        } else {
            Text("Image Unable to Load")
                .frame(width: 100, height: 48)
        }
    }
}
