//
//  Guide.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/11/2024.
//

import Foundation

struct Guide: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    
    static let guides = [
        Guide(title: "Incomplete View", content: "GThis section will be filled in progressively and mostly serves as placeholder for now"),
        Guide(title: "Google Plugin Settings", content: "Guide for configuring Google plugin settings..."),
        Guide(title: "URL Scrape Settings", content: "Instructions for setting up URL scraping..."),
        Guide(title: "Google Gemini Specific Plugins", content: "Information about Gemini-specific plugins..."),
        Guide(title: "General Plugins", content: "Overview of general plugins and their usage..."),
        Guide(title: "Adding New Providers", content: "Steps to add new AI providers to the app..."),
        Guide(title: "Adding Files", content: "Can read most text based files. audio file can be read by transcription tool..."),
        Guide(title: "Quick Panel Guide", content: "How to use and customize the Quick Panel feature...")
    ]
}
