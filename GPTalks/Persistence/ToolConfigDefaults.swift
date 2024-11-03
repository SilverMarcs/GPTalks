//
//  ToolConfigDefaults.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

class ToolConfigDefaults: ObservableObject {
    static let shared = ToolConfigDefaults()
    private init() {}
    
    @AppStorage("googleSearch") var googleSearch: Bool = false
    @AppStorage("urlScrape") var urlScrape: Bool = false
    @AppStorage("imageGenerate") var imageGenerate: Bool = false
    @AppStorage("transcribe") var transcribe: Bool = false
    @AppStorage("pdfReader") var pdfReader: Bool = false
    
    // Google Service only
    @AppStorage("googleCodeExecution") var googleCodeExecution: Bool = false
    @AppStorage("googleSearchRetrieval") var googleSearchRetrieval: Bool = false
    
    // url scrape
    @AppStorage("urlMaxContentLength") var urlMaxContentLength: Int = 10000
    
    // pdf reader
    @AppStorage("pdfMaxContentLength") var pdfMaxContentLength: Int = 10000
    
    // google search
    @AppStorage("googleApiKey") var googleApiKey: String = ""
    @AppStorage("googleSearchEngineId") var googleSearchEngineId: String = ""
    @AppStorage("gSearchCount") var gSearchCount: Int = 7
}
