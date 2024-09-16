//
//  ToolConfigDefaults.swift
//  GPTalks
//
//  Created by Zabir Raihan on 15/09/2024.
//

import SwiftUI

class ToolConfigDefaults: ObservableObject {
    static let shared = ToolConfigDefaults()
    
    @AppStorage("googleSearch") var googleSearch: Bool = false
    @AppStorage("urlScrape") var urlScrape: Bool = false
    @AppStorage("imageGenerate") var imageGenerate: Bool = false
    @AppStorage("transcribe") var transcribe: Bool = false
    
    // url scrape
    @AppStorage("maxContentLength") var maxContentLength: Int = 5000
    
    // google search
    @AppStorage("googleApiKey") var googleApiKey: String = ""
    @AppStorage("googleSearchEngineId") var googleSearchEngineId: String = ""
    @AppStorage("gSearchCount") var gSearchCount: Int = 7
}
