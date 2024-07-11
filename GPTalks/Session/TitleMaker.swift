//
//  TitleMaker.swift
//  GPTalks
//
//  Created by Zabir Raihan on 11/07/2024.
//

import Foundation

class TitleMaker {
    static func makeTitle(for fileName: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: Date())
        
        return """
        //
        //  \(fileName)
        //  GPTalks
        //
        //  Created by Zabir Raihan on \(dateString).
        //
        """
    }
}
