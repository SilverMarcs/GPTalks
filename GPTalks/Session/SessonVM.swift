//
//  SessonVM.swift
//  GPTalks
//
//  Created by Zabir Raihan on 04/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Observable class SessionVM {
    var selections: Set<Session> = []
    var selection: Session?
    var searchText: String = ""
    
    var chatCount: Int = 12
}
