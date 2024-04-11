//
//  PDFExtractor.swift
//  GPTalks
//
//  Created by Zabir Raihan on 07/04/2024.
//

import SwiftUI
import PDFKit

func extractTextFromPDF(at url: URL) -> String {
    guard let pdfDocument = PDFDocument(url: url) else {
        print("Failed to create PDF document")
        return ""
    }
    
    var extractedText = ""
    for index in 0..<pdfDocument.pageCount {
        guard let page = pdfDocument.page(at: index) else { continue }
        if let text = page.string {
            extractedText += text
        }
    }
    
    return extractedText
}
