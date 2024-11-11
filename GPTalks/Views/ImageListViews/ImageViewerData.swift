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
    @State var isHovering = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
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
            
            if isHovering {
                Button(action: saveImage) {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .font(.largeTitle)
                        .rotationEffect(.degrees(180))
                }
                .foregroundStyle(.white, .black.tertiary)
                .buttonStyle(.plain)
                .padding(10)
            }
        }
        .onHover { isHovering = $0 }
    }
    
    func onTap() {
        if let url = FileHelper.createTemporaryURL(for: data) {
            selectedFileURL = url
        }
    }
    
    func saveImage() {
        guard let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            print("Unable to access Downloads directory")
            return
        }
        
        let fileName = UUID().uuidString + "_image.png"
        let fileURL = downloadsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            print("Image saved to \(fileURL.path)")
        } catch {
            print("Error saving image: \(error)")
        }
    }
}
