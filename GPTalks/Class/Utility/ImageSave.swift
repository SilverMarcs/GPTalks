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

func saveImageData(imageData: Data) {
    #if os(iOS)
        saveImageDataToPhotos(imageData: imageData)
    #elseif os(macOS)
        saveImageDataWithPopup(imageData: imageData)
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


// Function to save an image to disk and return its URL
func saveImageToDisk(image: UIImage) -> URL? {
    guard let data = image.pngData() else { return nil }
    let fileName = UUID().uuidString + ".png"
    if let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
        let filePath = directory.appendingPathComponent(fileName)
        do {
            try data.write(to: filePath)
            return filePath
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    return nil
}

// Function to retrieve an image from disk
func retrieveImageFromDisk(url: URL) -> UIImage? {
    do {
        let data = try Data(contentsOf: url)
        return UIImage(data: data)
    } catch {
        print("Error retrieving image: \(error)")
        return nil
    }
}

//func saveImage(image: UIImage, fileName: String = UUID().uuidString, inFolder folderName: String = "GPTalksImages") -> Bool {
//    guard let data = image.jpegData(compressionQuality: 0.7) ?? image.pngData() else {
//        return false
//    }
//    
//    do {
//        let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        let folderURL = directory.appendingPathComponent(folderName, isDirectory: true)
//        
//        // Check if the folder exists, if not, create it
//        if !FileManager.default.fileExists(atPath: folderURL.path) {
//            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
//        }
//        
//        let fileURL = folderURL.appendingPathComponent(fileName)
//        try data.write(to: fileURL)
//        return true
//    } catch {
//        print(error.localizedDescription)
//        return false
//    }
//}
//
//func getSavedImage(named: String, fromFolder folderName: String = "GPTalksImages") -> UIImage? {
//    do {
//        let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        let folderURL = directory.appendingPathComponent(folderName, isDirectory: true)
//        let fileURL = folderURL.appendingPathComponent(named)
//        
//        return UIImage(contentsOfFile: fileURL.path)
//    } catch {
//        print(error.localizedDescription)
//        return nil
//    }
//}

//func saveImage(image: UIImage, fileName: String = UUID().uuidString, inFolder folderName: String = "GPTalksImages") -> String? {
//    guard let data = image.jpegData(compressionQuality: 0.7) ?? image.pngData() else {
//        return nil
//    }
//    
//    do {
//        let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        let folderURL = directory.appendingPathComponent(folderName, isDirectory: true)
//        
//        // Check if the folder exists, if not, create it
//        if !FileManager.default.fileExists(atPath: folderURL.path) {
//            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
//        }
//        
//        let fileURL = folderURL.appendingPathComponent(fileName)
//        try data.write(to: fileURL)
//        return fileURL.path
//    } catch {
//        print(error.localizedDescription)
//        return nil
//    }
//}
//
//func getSavedImage(fromPath filePath: String) -> UIImage? {
//    print(filePath)
//    return UIImage(contentsOfFile: filePath)
//}

func saveImage(image: UIImage, fileName: String = UUID().uuidString, inFolder folderName: String = "GPTalksImages") -> String? {
    guard let data = image.jpegData(compressionQuality: 0.7) ?? image.pngData() else {
        return nil
    }
    
    do {
        let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let folderURL = directory.appendingPathComponent(folderName, isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        let fileURL = folderURL.appendingPathComponent(fileName)
        try data.write(to: fileURL)
        // Return only the relative path
        return folderName + "/" + fileName
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

// path is relative path
func getSavedImage(fromPath filePath: String) -> UIImage? {
    do {
        let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = directory.appendingPathComponent(filePath)
        return UIImage(contentsOfFile: fileURL.path)
    } catch {
        print(error.localizedDescription)
        return nil
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
    }
    .resume()
}

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

func saveImageToDisk(image: NSImage) -> URL? {
    guard let data = image.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: data),
          let pngData = bitmapImage.representation(using: .png, properties: [:]) else { return nil }
    let fileName = UUID().uuidString + ".png"
    if let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
        let filePath = directory.appendingPathComponent(fileName)
        do {
            try pngData.write(to: filePath)
            return filePath
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    return nil
}

func retrieveImageFromDisk(url: URL) -> NSImage? {
    do {
        let data = try Data(contentsOf: url)
        return NSImage(data: data)
    } catch {
        print("Error retrieving image: \(error)")
        return nil
    }
}

//func saveImage(image: NSImage, fileName: String, inFolder folderName: String = "GPTalksImages") -> Bool {
//    guard let data = image.tiffRepresentation else {
//        return false
//    }
//    
//    do {
//        // Use .picturesDirectory or .applicationSupportDirectory
//        let directory = try FileManager.default.url(for: .picturesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        let folderURL = directory.appendingPathComponent(folderName, isDirectory: true)
//        
//        // Check if the folder exists, if not, create it
//        if !FileManager.default.fileExists(atPath: folderURL.path) {
//            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
//         }
//        
//        let fileURL = folderURL.appendingPathComponent(fileName + ".png")
//        try data.write(to: fileURL)
//        return true
//    } catch {
//        print(error.localizedDescription)
//        return false
//    }
//}
//
//func getSavedImage(named: String, fromFolder folderName: String = "GPTalksImages") -> NSImage? {
//    do {
//        // Use .picturesDirectory or .applicationSupportDirectory
//        let directory = try FileManager.default.url(for: .picturesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        let folderURL = directory.appendingPathComponent(folderName, isDirectory: true)
//        let fileURL = folderURL.appendingPathComponent(named + ".png")
//        
//        return NSImage(contentsOf: fileURL)
//    } catch {
//        print(error.localizedDescription)
//        return nil
//     }
// }
//
//func saveImage(image: NSImage, fileName: String = UUID().uuidString, inFolder folderName: String = "GPTalksImages") -> String? {
//    guard let data = image.tiffRepresentation,
//          let bitmapImage = NSBitmapImageRep(data: data),
//          let imageData = bitmapImage.representation(using: .png, properties: [:]) else {
//        return nil
//    }
//    
//    do {
//        let directory = try FileManager.default.url(for: .picturesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        let folderURL = directory.appendingPathComponent(folderName, isDirectory: true)
//        
//        if !FileManager.default.fileExists(atPath: folderURL.path) {
//            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
//        }
//        
//        let fileURL = folderURL.appendingPathComponent("\(fileName).png")
//        try imageData.write(to: fileURL)
//        return fileURL.path
//    } catch {
//        print(error.localizedDescription)
//        return nil
//    }
//}
//
//func getSavedImage(fromPath filePath: String) -> NSImage? {
//    return NSImage(contentsOfFile: filePath)
//}

func saveImage(image: NSImage, fileName: String = UUID().uuidString, inFolder folderName: String = "GPTalksImages") -> String? {
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
        // Return only the relative path
        return folderName + "/" + fileName + ".png"
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

// relative path
func getSavedImage(fromPath filePath: String) -> NSImage? {
    do {
        let directory = try FileManager.default.url(for: .picturesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = directory.appendingPathComponent(filePath)
        return NSImage(contentsOf: fileURL)
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

#endif
