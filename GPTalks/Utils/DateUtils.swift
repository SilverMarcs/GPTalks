//
//  DateUtils.swift
//  GPTalks
//
//  Created by Zabir Raihan on 10/07/2024.
//

import Foundation

extension Date {
    func nowFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmssSSS"
        return formatter.string(from: self)
    }
}
