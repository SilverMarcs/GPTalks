//
//  GenericModel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/10/2024.
//

import Foundation

struct GenericModel: Identifiable, Hashable {
    var id: UUID = UUID()
    var code: String
    var name: String
    var isSelected: Bool = false
    var selectedModelType: ModelType = .chat
}
