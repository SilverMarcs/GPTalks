//
//  ImageUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import SwiftUI

struct CustomImageViewModifier: ViewModifier {
    let padding: CGFloat
    let imageSize: CGFloat
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .foregroundStyle(.secondary)
            .background(color)
            .frame(width: imageSize, height: imageSize)
            .clipShape(Rectangle())
    }
}


#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

extension Image {
    func customImageStyle(padding: CGFloat = 0, imageSize: CGFloat, color: Color = .clear) -> some View {
        self
            .resizable()
            .modifier(CustomImageViewModifier(padding: padding, imageSize: imageSize, color: color))
    }
    
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

#Preview {
    Image(systemName: "arrow.2.circlepath")
        .customImageStyle(imageSize: 20)
}
