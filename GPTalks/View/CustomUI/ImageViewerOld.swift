//
//  ImageViewer.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/07/2024.
//

import SwiftUI
import QuickLook

struct ImageViewerOld: View {
    let imagePath: String
    let onRemove: () -> Void
    
    var maxWidth: CGFloat
    var maxHeight: CGFloat
    var radius: CGFloat
    
    var isCrossable: Bool
    
    @State var qlItem: URL?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = Image(filePath: imagePath) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    .clipShape(RoundedRectangle(cornerRadius: radius))
            }
            
            if isCrossable {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white)
                }
                .shadow(radius: 5)
                .buttonStyle(.plain)
                .padding(5)
            }
        }
        .onTapGesture {
            setupQLItem()
        }
        .quickLookPreview($qlItem)
    }
    
    private func setupQLItem() {
#if os(macOS) || targetEnvironment(macCatalyst)
        qlItem = URL(string: imagePath)!
#else
        if let fileURL = imagePath.absoluteURL() {
            qlItem = fileURL
        }
#endif
    }
    
    init(imagePath: String, maxWidth: CGFloat = 100, maxHeight: CGFloat = 100, radius: CGFloat = 7, isCrossable: Bool = true, onRemove: @escaping () -> Void) {
        self.imagePath = imagePath
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.radius = radius
        self.onRemove = onRemove
        self.isCrossable = isCrossable
    }
}

#Preview {
    let path = "file:///Users/Zabir/Pictures/Screenshots/zdontdelete.png"
    
//    ImageViewer(imagePath: path, maxWidth: .infinity) {}
    ImageViewerOld(imagePath: path, maxWidth: .infinity) {}
}
