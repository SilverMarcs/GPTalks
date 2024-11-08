//
//  FileHelper.swift
//  GPTalks
//
//  Created by Zabir Raihan on 24/07/2024.
//

import Foundation

struct FileHelper {
    static func createTemporaryURL(for typedData: TypedData) -> URL? {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let fileName = typedData.fileName
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
        let fileName = "temp_\(UUID().uuidString)"
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
    
    static func processDataFiles(_ dataFiles: [TypedData], threadId: String, role: ThreadRole) -> [ContentItem] {
        return dataFiles.map { data in
            if data.fileType.conforms(to: .text) || data.fileType.conforms(to: .pdf) {
                return .text(data.formattedTextContent)
            } else if data.fileType.conforms(to: .image) && role == .user {
                return .image(data.mimeType, data.data)
            } else {
                let warning = "Notify the user if a file has been added but the assistant could not find a compatible plugin to read that file type."
                return .text("Thread ID: \(threadId)\nFile: \(data.fileName)\n\(warning)")
            }
        }
    }
    
    enum ContentItem {
        case text(String)
        case image(String, Data)  // mimeType, data
    }
}
