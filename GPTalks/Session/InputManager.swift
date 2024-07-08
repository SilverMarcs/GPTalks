//
//  InputManager.swift
//  GPTalks
//
//  Created by Zabir Raihan on 25/06/2024.
//

import SwiftUI

@Observable class InputManager {
    var prompt: String = ""
    
    init() {
        
    }
    
    func reset() {
        prompt = ""
    }
}
