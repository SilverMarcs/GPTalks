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
        #if os(macOS)
        guard let url = URL(string: filePath),
              let platformImage = PlatformImage(contentsOf: url) else {
            return nil
        }
        self.init(platformImage: platformImage)
        #else
        guard let data = loadImageData(from: filePath),
              let platformImage = PlatformImage(data: data) else {
            return nil
        }
        self.init(platformImage: platformImage)
        #endif
    }
}

extension PlatformImage {
    #if os(macOS)
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
    #else
    func save(fileName: String = Date().nowFileName(), inFolder folderName: String = "GPTalks") -> String? {
        var imageData: Data? = nil
        var fileType: String = ""
        
        if let jpegData = self.jpegData(compressionQuality: 0.7) {
            imageData = jpegData
            fileType = ".jpg"
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
    #endif
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
                    #if os(macOS)
                    if let image = NSImage(contentsOf: url) {
                        onImageAppend?(image)
                    }
                    #else
                    if let image = UIImage(contentsOfFile: url.path) {
                        onImageAppend?(image)
                    }
                    #endif
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

#if os(mac)
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
#else
func loadImageData(from filePath: String) -> Data? {
    guard let url = URL(string: filePath),
          let data = try? Data(contentsOf: url) else {
        return nil
    }
    return data
}
#endif

#Preview {
    Image(systemName: "arrow.2.circlepath")
//        .customImageStyle(imageSize: 20)
}
