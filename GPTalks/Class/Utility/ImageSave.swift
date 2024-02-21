//
//  ImageSave.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/02/2024.
//

import Foundation
import SwiftUI
import Photos

func saveImage(url: URL) {
    #if os(iOS)
        saveImageToPhotos(url: url)
    #elseif os(macOS)
        saveImageWithPopup(url: url)
    #else
        print("Not supported.")
    #endif
}

#if os(iOS)
    private func saveImageToPhotos(url: URL?) {
        guard let url = url else { return }

        // Request permission to save to the photo library
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // Download the image data
                URLSession.shared.dataTask(with: url) { data, _, error in
                    guard let data = data, let image = UIImage(data: data), error == nil else { return }

                    // Save the image to the photo library
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { success, error in
                        if let error = error {
                            print("Error saving image to Photos: \(error)")
                        } else if success {
                            print("Image successfully saved to Photos")
                        }
                    }
                }.resume()
            } else {
                print("Permission to access the photo library was denied.")
            }
        }
    }
#endif

#if os(macOS)
    private func saveImageWithPopup(url: URL?) {
        guard let url = url else { return }

        // Download the image data
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, let image = NSImage(data: data), error == nil else { return }

            DispatchQueue.main.async {
                // Present the save panel to the user
                let savePanel = NSSavePanel()
                savePanel.allowedContentTypes = [.image] // You can add more file types
                savePanel.canCreateDirectories = true
                savePanel.nameFieldStringValue = url.deletingPathExtension().lastPathComponent + ".png"

                if savePanel.runModal() == .OK, let saveURL = savePanel.url {
                    // Save the image to the selected location
                    if let tiffData = image.tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffData) {
                        let imageData = bitmapImage.representation(using: .png, properties: [:])
                        do {
                            try imageData?.write(to: saveURL)
                            print("Image successfully saved to \(saveURL.path)")
                        } catch {
                            print("Error saving image: \(error)")
                        }
                    }
                }
            }
        }.resume()
    }
#endif
