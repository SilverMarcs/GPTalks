//
//  PageDots.swift
//  GPTalks
//
//  Created by Zabir Raihan on 17/11/2024.
//

import SwiftUI

struct PageDots: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(current == index ? Color.blue : Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
