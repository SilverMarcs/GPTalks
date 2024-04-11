//
//  ImageSave.swift
//  GPTalks
//
//  Created by Zabir Raihan on 14/02/2024.
//

import Foundation
import SwiftUI
import Photos

func saveImageData(imageData: Data) {
    #if os(iOS)
        saveImageDataToPhotos(imageData: imageData)
    #elseif os(macOS)
        saveImageDataWithPopup(imageData: imageData)
    #else
        print("Not supported.")
    #endif
}

#if os(macOS)

private func saveImageDataWithPopup(imageData: Data) {
    // Present the save panel to the user
    DispatchQueue.main.async {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png] // You can add more file types
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "image.png"

        if savePanel.runModal() == .OK, let saveURL = savePanel.url {
            // Save the image to the selected location
            do {
                try imageData.write(to: saveURL)
                print("Image successfully saved to \(saveURL.path)")
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }
}

// absolute
func saveImage(image: NSImage, fileName: String = Date().nowFileName(), inFolder folderName: String = "GPTalksImages") -> String? {
    guard let data = image.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: data),
          let imageData = bitmapImage.representation(using: .png, properties: [:]) else {
        return nil
    }
    
    do {
        let directory = try FileManager.default.url(for: .picturesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let folderURL = directory.appendingPathComponent(folderName, isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        let fileURL = folderURL.appendingPathComponent("\(fileName).png")
        try imageData.write(to: fileURL)
        // Return the whole file URL as a string
        return fileURL.absoluteString
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

// absolute
func loadImage(from filePath: String) -> NSImage? {
    // Convert the string to a URL
    guard let fileURL = URL(string: filePath) else {
        print("Invalid URL")
        return nil
    }
    
    // Attempt to create an NSImage object with the contents of the file
    let image = NSImage(contentsOf: fileURL)
    if image == nil {
        print("Error loading image from file")
    }
    return image
}

// absolute
func loadImageData(from filePath: String) -> Data? {
    // Convert the string to a URL
    guard let fileURL = URL(string: filePath) else {
        print("Invalid URL")
        return nil
    }
    
    do {
        // Attempt to create a Data object with the contents of the file
        let data = try Data(contentsOf: fileURL)
        return data
    } catch {
        // If there was an error loading the file, print the error
        print("Error loading data from file: \(error)")
        return nil
    }
}

func getImageFromClipboard() -> NSImage? {
    let pasteboard = NSPasteboard.general

    // Check for file URLs on the pasteboard
    if let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
       let fileURL = fileURLs.first {
        // Attempt to create an NSImage from the file URL
        return NSImage(contentsOf: fileURL)
    }
    // If there are no file URLs, attempt to read image data directly
    else if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
        return image
    }
    
    // If no image was found, return nil
    return nil
}

#else

private func saveImageDataToPhotos(imageData: Data) {
    // Request permission to save to the photo library
    PHPhotoLibrary.requestAuthorization { status in
        if status == .authorized, let image = UIImage(data: imageData) {
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
        } else {
            print("Permission to access the photo library was denied or image data is invalid.")
        }
    }
}

// relative
func saveImage(image: UIImage, fileName: String = Date().nowFileName(), inFolder folderName: String = "GPTalksImages") -> String? {
    var imageData: Data? = nil
    var fileType: String = ""
    
    if let jpegData = image.jpegData(compressionQuality: 0.7) {
        imageData = jpegData
        fileType = ".jpg"
    } else if let pngData = image.pngData() {
        imageData = pngData
        fileType = ".png"
    }
    
    guard let data = imageData else {
        return nil
    }
    
    do {
        let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let folderURL = directory.appendingPathComponent(folderName, isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        let fullFileName = fileName + fileType
        let fileURL = folderURL.appendingPathComponent(fullFileName)
        
        try data.write(to: fileURL)
        
        // Return the relative path from the Documents directory
        return folderName + "/" + fullFileName
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

// relative
func loadImage(from filePath: String) -> UIImage? {
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return nil
    }
    let fileURL = documentsDirectory.appendingPathComponent(filePath)
    return UIImage(contentsOfFile: fileURL.path)
}

// relative
func loadImageData(from filePath: String) -> Data? {
    // Get the URL for the app's document directory
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Documents directory not found.")
        return nil
    }
    
    // Append the relative path to the documents directory to form the full file URL
    let fileURL = documentsDirectory.appendingPathComponent(filePath)
    
    // Attempt to load and return the data from the file URL
    do {
        let data = try Data(contentsOf: fileURL)
        return data
    } catch {
        print("Failed to load data: \(error.localizedDescription)")
        return nil
    }
}

func absoluteURL(forRelativePath relativePath: String) -> URL? {
    // Get the URL for the Documents directory
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return nil
    }
    
    // Append the relative path to the Documents directory URL
    let fileURL = documentsDirectory.appendingPathComponent(relativePath)
    
    return fileURL
}

#endif

