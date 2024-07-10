//
//  ImageUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

extension Image {
    init(platformImage: PlatformImage) {
#if os(macOS)
        self.init(nsImage: platformImage)
#else
        self.init(uiImage: platformImage)
#endif
    }
    
    init?(filePath: String) {
        guard let url = URL(string: filePath),
              let platformImage = PlatformImage(contentsOf: url) else {
            return nil
        }
        self.init(platformImage: platformImage)
    }
}

extension PlatformImage {
    func save(fileName: String = Date().nowFileName(), inFolder folderName: String = "GPTalks") -> String? {
        guard let data = self.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: data),
              let imageData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.7]) else {
            return nil
        }
        
        do {
            let directory = try FileManager.default.url(for: .picturesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let folderURL = directory.appendingPathComponent(folderName, isDirectory: true)
            
            if !FileManager.default.fileExists(atPath: folderURL.path) {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            }
            
        let fileURL = folderURL.appendingPathComponent("\(fileName).jpg")
            if FileManager.default.createFile(atPath: fileURL.path, contents: imageData, attributes: nil) {
                return fileURL.absoluteString
            } else {
                return nil
            }
 
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

extension View {
    func imageFileImporter(isPresented: Binding<Bool>, onImageAppend: ((PlatformImage) -> Void)?) -> some View {
        self.fileImporter(
            isPresented: isPresented,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    if let image = NSImage(contentsOf: url) {
                        onImageAppend?(image)
                    }
                }
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
    }
}

func loadImageAsBase64(from imagePath: String) -> String? {
    guard let url = URL(string: imagePath),
          let imageData = try? Data(contentsOf: url) else {
        return nil
    }
    return imageData.base64EncodedString()
}

import Foundation

//func loadImageData(from imagePath: String) -> Data? {
//    guard let url = URL(string: imagePath) else {
//        print("Invalid URL from image path: \(imagePath)")
//        return nil
//    }
//    
//    do {
//        let imageData = try Data(contentsOf: url)
//        return imageData
//    } catch {
//        print("Error loading image data from path: \(imagePath)")
//        print("Error details: \(error)")
//        return nil
//    }
//}

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

#Preview {
    Image(systemName: "arrow.2.circlepath")
//        .customImageStyle(imageSize: 20)
}
