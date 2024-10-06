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
    var order: Int = 0

    var code: String
    var name: String
    var isEnabled: Bool = true
    var lastTestResult: Bool?

    init(code: String, name: String, order: Int = .max, isEnabled: Bool = true, lastTestResult: Bool? = nil) {
        self.code = code
        self.name = name
        self.order = order
        self.isEnabled = isEnabled
        self.lastTestResult = lastTestResult
    }
}
