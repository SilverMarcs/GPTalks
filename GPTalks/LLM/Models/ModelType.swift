//
//  ModelType.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/10/2024.
//

import Foundation

protocol ModelType: Hashable, Identifiable, Codable {
    var id: UUID { get }
    var code: String { get set }
    var name: String { get set }
    init(code: String, name: String)
}
