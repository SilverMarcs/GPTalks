//
//  TreeItem.swift
//  GPTalks
//
//  Created by Zabir Raihan on 8/12/24.
//

import SwiftUI

protocol TreeItem: Identifiable, Hashable {
    var id: UUID { get }
    var title: String { get }
//    var children: [any TreeItem]? { get }
}

struct AnyTreeItem: Identifiable, Hashable {
    let wrappedItem: any TreeItem
    
    var id: UUID { wrappedItem.id }
    var title: String { wrappedItem.title }
    
    init(_ item: any TreeItem) {
        self.wrappedItem = item
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AnyTreeItem, rhs: AnyTreeItem) -> Bool {
        lhs.id == rhs.id
    }
    
    var unwrapped: any TreeItem {
        wrappedItem
    }
}
