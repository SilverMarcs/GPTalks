//
//  FlippingText.swift
//  GPTalks
//
//  Created by Zabir Raihan on 02/12/2024.
//

import SwiftUI

struct FlippingText: View {
    let text: [Character]
    @State private var flipAngle = Double.zero
    
    init(_ text: String) {
        self.text = Array(text)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text).indices, id: \.self) { index in
                Text(String(text[index]))
                    .rotation3DEffect(.degrees(flipAngle), axis: (x: 0, y: 1, z: 0))
                    .animation(.easeInOut(duration: 0.4).delay(Double(index) * 0.1), value: flipAngle)
            }
        }
        .onAppear {
            withAnimation {
                flipAngle = 360
            }
        }
    }
}
