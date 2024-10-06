//
//  TranscriptionModel.swift
//  GPTalks
//
//  Created by Zabir Raihan on 05/10/2024.
//

import Foundation
import SwiftData

@Model
final class TranscriptionModel: Hashable, Identifiable {
    var id: UUID = UUID()
    var code: String
    var name: String

    init(code: String, name: String) {
        self.code = code
        self.name = name
    }
}
