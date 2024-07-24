//
//  ArrayExtensions.swift
//  GPTalks
//
//  Created by Zabir Raihan on 06/07/2024.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    mutating func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        let reversedSource = source.sorted(by: >)
        for offset in reversedSource {
            insert(remove(at: offset), at: destination > offset ? destination - 1 : destination)
        }
    }
}

