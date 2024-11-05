//
//  IntegerStepper.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/09/2024.
//

import SwiftUI

struct IntegerStepper: View {
    @Binding var value: Int
    let label: String
    var secondaryLabel: String? = nil
    let step: Int
    let range: ClosedRange<Int>
    
    
    var body: some View {
        Stepper(
            value: Binding<Double>(
                get: { Double(value) },
                set: { value = Int($0) }
            ),
            in: Double(range.lowerBound)...Double(range.upperBound),
            step: Double(step),
            format: .number
        ) {
            Text(platformLabel)
            if let secondaryLabel = secondaryLabel {
                Text(secondaryLabel)
            }
        }
    }
    
    
    var platformLabel: String {
        #if os(macOS)
        label
        #else
        "\(label): (\(value))"
        #endif
    }
}

#Preview {
    @Previewable @State var value = 0
    
    IntegerStepper(value: $value, label: "Value", step: 1, range: 0...100)
}
