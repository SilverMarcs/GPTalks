//
//  TypedData.swift
//  GPTalks
//
//  Created by Zabir Raihan on 18/08/2024.
//

import SwiftData
import UniformTypeIdentifiers

struct TypedData: Codable {
    var data: Data
    var fileType: UTType
    var fileName: String
    var fileSize: String
    var fileExtension: String
    
    var mimeType: String {
        return fileType.preferredMIMEType ?? "application/octet-stream"
    }
}
