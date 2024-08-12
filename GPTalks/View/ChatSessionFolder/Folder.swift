//
//  Folder.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/12/24.
//

import SwiftUI
import SwiftData

@Model
class Folder: Identifiable, TreeItem {
    var id: UUID
    var title: String
    var order: Int
    @Relationship(deleteRule: .cascade, inverse: \Session.folder) var sessions: [Session] = []
    
    init(id: UUID = UUID(), title: String, order: Int) {
        self.id = id
        self.title = title
        self.order = order
    }
}
