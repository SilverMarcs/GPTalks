//
//  FileHelper.swift
//  GPTalks
//
//  Created by Zabir Raihan on 24/07/2024.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import QuickLook

struct FileHelper {
    static func deleteFile(at path: String) {
        do {
            #if os(macOS)
            if let fileURL = URL(string: path) {
                try Foundation.FileManager.default.removeItem(at: fileURL)
            }
            #else
            let documentsDirectory = try Foundation.FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentsDirectory.appendingPathComponent(path)
            try Foundation.FileManager.default.removeItem(at: fileURL)
            #endif
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }
    
    static func createTemporaryURL(for typedData: TypedData) -> URL? {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let fileName = typedData.fileName + "." + typedData.fileType.fileExtension
        let fileURL = tempDirectoryURL.appendingPathComponent(fileName)

        do {
            try typedData.data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error creating temporary file: \(error)")
            return nil
        }
    }
    
    static func createTemporaryURL(for data: Data) -> URL? {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let fileName = "temp_file_\(UUID().uuidString)"
        let fileExtension = inferFileExtension(from: data)
        let fullFileName = fileName + "." + fileExtension
        let fileURL = tempDirectoryURL.appendingPathComponent(fullFileName)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error creating temporary file: \(error)")
            return nil
        }
    }

    private static func inferFileExtension(from data: Data) -> String {
        // Check the first few bytes of the data to infer the file type
        let header = data.prefix(16)
        
        if header.starts(with: [0xFF, 0xD8, 0xFF]) {
            return "jpg"
        } else if header.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            return "png"
        } else if header.starts(with: [0x47, 0x49, 0x46, 0x38]) {
            return "gif"
        } else if header.starts(with: [0x25, 0x50, 0x44, 0x46]) {
            return "pdf"
        } else if header.starts(with: [0x50, 0x4B, 0x03, 0x04]) {
            return "zip"
        } else {
            // Default to binary if unable to infer
            return "bin"
        }
    }
}

extension View {
    @ViewBuilder
    func multipleFileImporter(isPresented: Binding<Bool>, inputManager: InputManager) -> some View {
        self.fileImporter(
            isPresented: isPresented,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                Task {
                    for url in urls {
                        do {
                            try await inputManager.processFile(at: url)
                        } catch {
                            print("Failed to process file: \(url.lastPathComponent). Error: \(error)")
                        }
                    }
                }
            case .failure(let error):
                print("File selection error: \(error.localizedDescription)")
            }
        }
    }
}


