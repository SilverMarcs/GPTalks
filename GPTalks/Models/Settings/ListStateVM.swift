//
//  ListStateVM.swift
//  GPTalks
//
//  Created by Zabir Raihan on 08/11/2024.
//

import Foundation

@Observable class ListStateVM {
    var state: ListState = .chats
    
    enum ListState: String, CaseIterable {
        case chats
        case images
    }
}
