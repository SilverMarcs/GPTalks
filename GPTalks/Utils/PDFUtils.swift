//
//  PDFUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 20/08/2024.
//

import PDFKit

func readPDF(from url: URL) -> String {
    guard let document = PDFDocument(url: url) else {
        return "Unable to load PDF"
    }
    
    let pageCount = document.pageCount
    var content = ""
    
    for i in 0 ..< pageCount {
        guard let page = document.page(at: i) else { continue }
        guard let pageContent = page.string else { continue }
        content += pageContent
    }
    
    return content
}
