//
//  TypedData.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/08/2024.
//

import SwiftData
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#endif

struct TypedData: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var data: Data
    var fileType: UTType
    var fileName: String
    var fileSize: String
    var fileExtension: String
    
    var mimeType: String {
        return fileType.preferredMIMEType ?? "application/octet-stream"
    }
    
    var imageName: PlatformImage {
        #if os(macOS)
        NSWorkspace.shared.icon(for: self.fileType)
        #else
        PlatformImage(systemName: "doc.on.doc.fill")!
        #endif
    }
}
