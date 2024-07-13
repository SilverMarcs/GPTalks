//
//  ImageUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI
import PhotosUI

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
        guard let jpegData = self.jpegData(compressionQuality: 0.7) else {
            return nil
        }
        
        do {
            let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let folderURL = directory.appendingPathComponent(folderName, isDirectory: true)
            
            if !FileManager.default.fileExists(atPath: folderURL.path) {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            let fullFileName = fileName + ".jpg"
            let fileURL = folderURL.appendingPathComponent(fullFileName)
            
            try jpegData.write(to: fileURL)
            
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
    @ViewBuilder
    func imageFileImporter(isPresented: Binding<Bool>, onImageAppend: @escaping (PlatformImage) -> Void) -> some View {
#if os(macOS)
        self.fileImporter(
            isPresented: isPresented,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    if let image = NSImage(contentsOf: url) {
                        onImageAppend(image)
                    }
                }
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
#else
        self.modifier(ImagePickerModifier(isPresented: isPresented, onImageAppend: onImageAppend))
#endif
    }
}

#if !os(macOS)
struct ImagePickerModifier: ViewModifier {
    @Binding var isPresented: Bool
    let onImageAppend: (UIImage) -> Void
    @State private var selectedItems = [PhotosPickerItem]()
    
    func body(content: Content) -> some View {
        content
            .photosPicker(
                isPresented: $isPresented,
                selection: $selectedItems,
                maxSelectionCount: 5,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: selectedItems) {
                Task {
                    for item in selectedItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            DispatchQueue.main.async {
                                onImageAppend(uiImage)
                            }
                        }
                    }
                    selectedItems.removeAll()
                }
            }
    }
}
#endif


func loadImageAsBase64(from imagePath: String) -> String? {
    guard let url = URL(string: imagePath),
          let imageData = try? Data(contentsOf: url) else {
        return nil
    }
    return imageData.base64EncodedString()
}

import Foundation

#if os(macOS)
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
#endif

#Preview {
    Image(systemName: "arrow.2.circlepath")
//        .customImageStyle(imageSize: 20)
}
