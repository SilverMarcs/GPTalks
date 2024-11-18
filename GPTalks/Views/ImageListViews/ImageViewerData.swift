//
//  ImageViewerData.swift
//  GPTalks
//
//  Created by Zabir Raihan on 29/09/2024.
//

import SwiftUI
import Photos

struct ImageViewerData: View {
    @ObservedObject var imageConfig = ImageConfigDefaults.shared
    let data: Data
    private let size: CGFloat = 300
    
    @State private var selectedFileURL: URL?
    @State private var isHovering = true
    @State private var showCheckmark = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                if let image = PlatformImage.from(data: data) {
                    Image(platformImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Text("Image Unable to Load")
                        .foregroundStyle(.red)
                        .frame(width: size, height: size)
                }
            }
            .quickLookPreview($selectedFileURL)
            .buttonStyle(.plain)
            
            if isHovering {
                Button(action: saveImage) {
                    Image(systemName: showCheckmark ? "checkmark.circle.fill" : "square.and.arrow.up.circle.fill")
                        .font(.largeTitle)
                        .rotationEffect(.degrees(showCheckmark ? 0 : 180))
                }
                .foregroundStyle(.white, .black.tertiary)
                .buttonStyle(.plain)
                .padding(10)
            }
        }
        #if os(macOS)
        .onHover { isHovering = $0 }
        #endif
    }
    
    func onTap() {
        if let url = FileHelper.createTemporaryURL(for: data) {
            selectedFileURL = url
        }
    }
    
    func saveImage() {
        if imageConfig.saveToPhotos {
            let image = PlatformImage(data: data)
            
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    print("No access to photo library")
                    return
                }
                
                if let image = image {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { success, error in
                        if success {
                            print("Image saved to Photos")
                            DispatchQueue.main.async {
                                showCheckmark = true
                                
                                // Revert back to the original icon after 2 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showCheckmark = false
                                }
                            }
                        } else if let error = error {
                            print("Error saving image to Photos: \(error)")
                        }
                    }
                } else {
                    print("Error creating UIImage from data")
                }
            }
        } else {
            guard let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
                print("Unable to access Downloads directory")
                return
            }
            
            let fileName = UUID().uuidString + "_image.png"
            let fileURL = downloadsDirectory.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                print("Image saved to \(fileURL.path)")
                
                showCheckmark = true
                
                // Revert back to the original icon after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showCheckmark = false
                }
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }
}
